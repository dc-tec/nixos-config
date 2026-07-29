{
  lib,
  pkgs,
  publicKeys,
  ...
}:
let
  privateKeyFile = "/var/lib/forge-secrets/radicle-node";
  metricDirectory = "/var/lib/prometheus-node-exporter-text-files";
  nodePort = 8776;
  radSystem = "/run/current-system/sw/bin/rad-system";

  seedRepositories = [
    "rad:z4FGmdE1XLWBUPTNBe4cJUQvJ5WyX" # nixos-config
  ];

  seedRepositoriesScript = pkgs.writeShellApplication {
    name = "forge-radicle-seed";
    text = ''
      repositories=(${lib.escapeShellArgs seedRepositories})
      for rid in "''${repositories[@]}"; do
        /run/current-system/sw/bin/rad-system seed \
          --scope followed \
          --timeout 2min \
          "$rid"
      done
    '';
  };

  radicleMetrics = pkgs.writeShellApplication {
    name = "forge-radicle-metrics";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.gnugrep
      pkgs.iproute2
      pkgs.systemd
    ];
    text = ''
      target="${metricDirectory}/forge_radicle.prom"
      temporary="$target.$$"
      trap 'rm -f -- "$temporary"' EXIT

      if [[ -s "${privateKeyFile}" ]]; then
        identity_present=1
      else
        identity_present=0
      fi

      if systemctl is-active --quiet radicle-node.service; then
        node_active=1
      else
        node_active=0
      fi

      if ss --no-header --listening --tcp --numeric \
        "sport = :${toString nodePort}" | grep --quiet .; then
        tcp_listening=1
      else
        tcp_listening=0
      fi

      if [[ "$node_active" == 1 ]] \
        && timeout 10s ${radSystem} node status >/dev/null 2>&1; then
        control_ready=1
      else
        control_ready=0
      fi

      repository_metrics=()
      repositories=(${lib.escapeShellArgs seedRepositories})
      for rid in "''${repositories[@]}"; do
        if timeout 15s ${radSystem} inspect "$rid" --identity >/dev/null 2>&1; then
          repository_present=1
        else
          repository_present=0
        fi

        policy_output="$(
          timeout 15s ${radSystem} inspect "$rid" --policy 2>/dev/null || true
        )"
        # The backticks are literal characters in the rad-system output.
        # shellcheck disable=SC2016
        if grep --fixed-strings --quiet 'scope `followed`' <<< "$policy_output"; then
          seed_policy_applied=1
        else
          seed_policy_applied=0
        fi

        repository_metrics+=(
          "forge_radicle_repository_present{rid=\"$rid\"} $repository_present"
          "forge_radicle_seed_policy_applied{rid=\"$rid\"} $seed_policy_applied"
        )
      done

      printf '%s\n' \
        '# HELP forge_radicle_identity_present Whether the Forge Radicle node private key is provisioned.' \
        '# TYPE forge_radicle_identity_present gauge' \
        "forge_radicle_identity_present $identity_present" \
        '# HELP forge_radicle_node_active Whether the Forge Radicle node service is active.' \
        '# TYPE forge_radicle_node_active gauge' \
        "forge_radicle_node_active $node_active" \
        '# HELP forge_radicle_tcp_listening Whether the Forge Radicle protocol port is listening.' \
        '# TYPE forge_radicle_tcp_listening gauge' \
        "forge_radicle_tcp_listening $tcp_listening" \
        '# HELP forge_radicle_control_ready Whether the Forge Radicle administrative interface responds.' \
        '# TYPE forge_radicle_control_ready gauge' \
        "forge_radicle_control_ready $control_ready" \
        '# HELP forge_radicle_repository_present Whether a declared Radicle repository is present and has a valid identity.' \
        '# TYPE forge_radicle_repository_present gauge' \
        '# HELP forge_radicle_seed_policy_applied Whether a declared Radicle repository has the followed seeding policy.' \
        '# TYPE forge_radicle_seed_policy_applied gauge' \
        "''${repository_metrics[@]}" \
        '# HELP forge_radicle_last_scan_timestamp_seconds Unix timestamp of the last Radicle metrics scan.' \
        '# TYPE forge_radicle_last_scan_timestamp_seconds gauge' \
        "forge_radicle_last_scan_timestamp_seconds $(date +%s)" \
        > "$temporary"

      chmod 0644 "$temporary"
      mv --force -- "$temporary" "$target"
    '';
  };
in
{
  assertions = [
    {
      assertion = lib.hasPrefix "ssh-ed25519 " publicKeys.radicle.forge;
      message = "The Forge Radicle node public key must be an Ed25519 SSH public key.";
    }
    {
      assertion = builtins.length (lib.splitString " " publicKeys.radicle.forge) == 2;
      message = "The Forge Radicle node public key must not contain an SSH comment.";
    }
  ];

  services.radicle = {
    enable = true;
    package = pkgs.radicle-node;
    privateKey = privateKeyFile;
    publicKey = publicKeys.radicle.forge;

    node = {
      listenAddress = "0.0.0.0";
      listenPort = nodePort;
      openFirewall = true;
    };

    settings.node = {
      alias = "radicle.decort.tech";
      externalAddresses = [ "radicle.decort.tech:${toString nodePort}" ];
      seedingPolicy.default = "block";
    };
  };

  systemd = {
    services = {
      radicle-node = {
        unitConfig.ConditionPathExists = privateKeyFile;
        serviceConfig = {
          MemoryHigh = "1G";
          MemoryMax = "2G";
          TasksMax = 256;
        };
      };

      forge-radicle-seed = {
        description = "Apply the Forge Radicle repository seeding policy";
        wantedBy = [ "multi-user.target" ];
        requires = [ "radicle-node.service" ];
        after = [ "radicle-node.service" ];
        unitConfig.ConditionPathExists = privateKeyFile;
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = lib.getExe seedRepositoriesScript;
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateTmp = true;
          ProtectHome = true;
          ProtectSystem = "strict";
          RestrictAddressFamilies = [
            "AF_UNIX"
            "AF_NETLINK"
          ];
        };
      };

      forge-radicle-metrics = {
        description = "Collect Forge Radicle node metrics";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = lib.getExe radicleMetrics;
          User = "root";
          Group = "root";
          UMask = "0022";
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateTmp = true;
          ProtectHome = true;
          ProtectSystem = "strict";
          ReadOnlyPaths = [ "-${privateKeyFile}" ];
          ReadWritePaths = [ metricDirectory ];
          RestrictAddressFamilies = [
            "AF_UNIX"
            "AF_NETLINK"
          ];
        };
      };
    };

    timers.forge-radicle-metrics = {
      description = "Schedule Forge Radicle node metrics collection";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "2m";
        OnUnitActiveSec = "5m";
        Unit = "forge-radicle-metrics.service";
      };
    };

    tmpfiles.rules = [
      "d /var/lib/radicle 0750 radicle radicle -"
      "f /var/lib/radicle/.gitconfig 0644 radicle radicle -"
    ];
  };
}
