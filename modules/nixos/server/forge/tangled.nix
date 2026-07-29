{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  hostname = "knot.decort.tech";
  ownerDid = "did:plc:wrl7x5yocird6ep6472fkm3a";
  stateDir = "/var/lib/tangled-knot";
  repositoryDir = "${stateDir}/repos";
  databaseFile = "${stateDir}/knotserver.db";
  metricDirectory = "/var/lib/prometheus-node-exporter-text-files";
  publicListenAddress = "127.0.0.1:5555";
  internalListenAddress = "127.0.0.1:5444";

  knotMetrics = pkgs.writeShellApplication {
    name = "forge-tangled-knot-metrics";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.curl
      pkgs.findutils
      pkgs.gnugrep
      pkgs.iproute2
      pkgs.jq
      pkgs.systemd
    ];
    text = ''
      target="${metricDirectory}/forge_tangled_knot.prom"
      temporary="$target.$$"
      trap 'rm -f -- "$temporary"' EXIT

      if [[ -s "${databaseFile}" ]]; then
        database_present=1
      else
        database_present=0
      fi

      if systemctl is-active --quiet knot.service; then
        service_active=1
      else
        service_active=0
      fi

      if ss --no-header --listening --tcp --numeric \
        'sport = :5555' | grep --quiet '127.0.0.1:5555'; then
        http_listener_ready=1
      else
        http_listener_ready=0
      fi

      if ss --no-header --listening --tcp --numeric \
        'sport = :5444' | grep --quiet '127.0.0.1:5444'; then
        internal_listener_ready=1
      else
        internal_listener_ready=0
      fi

      if curl --fail --silent --show-error --max-time 10 \
        "https://${hostname}/" >/dev/null; then
        public_http_ready=1
      else
        public_http_ready=0
      fi

      owner_response="$(${lib.getExe pkgs.curl} \
        --fail \
        --silent \
        --show-error \
        --max-time 10 \
        "https://${hostname}/xrpc/sh.tangled.owner" 2>/dev/null || true)"
      if [[ "$(${lib.getExe pkgs.jq} -r '.owner // empty' \
        <<< "$owner_response" 2>/dev/null || true)" == "${ownerDid}" ]]; then
        owner_matches=1
      else
        owner_matches=0
      fi

      repository_count=0
      while IFS= read -r -d $'\0' repository; do
        if [[ -f "$repository/HEAD" ]]; then
          repository_count=$((repository_count + 1))
        fi
      done < <(
        find "${repositoryDir}" \
          -mindepth 1 -maxdepth 1 -type d -name 'did:*' -print0 \
          2>/dev/null || true
      )
      state_bytes="$(du --summarize --bytes "${stateDir}" 2>/dev/null \
        | cut --fields=1 || printf 0)"

      printf '%s\n' \
        '# HELP forge_tangled_knot_database_present Whether the Knot SQLite database exists.' \
        '# TYPE forge_tangled_knot_database_present gauge' \
        "forge_tangled_knot_database_present $database_present" \
        '# HELP forge_tangled_knot_service_active Whether the Knot systemd service is active.' \
        '# TYPE forge_tangled_knot_service_active gauge' \
        "forge_tangled_knot_service_active $service_active" \
        '# HELP forge_tangled_knot_http_listener_ready Whether the loopback HTTP listener is ready.' \
        '# TYPE forge_tangled_knot_http_listener_ready gauge' \
        "forge_tangled_knot_http_listener_ready $http_listener_ready" \
        '# HELP forge_tangled_knot_internal_listener_ready Whether the loopback administrative listener is ready.' \
        '# TYPE forge_tangled_knot_internal_listener_ready gauge' \
        "forge_tangled_knot_internal_listener_ready $internal_listener_ready" \
        '# HELP forge_tangled_knot_public_http_ready Whether the public TLS endpoint is reachable.' \
        '# TYPE forge_tangled_knot_public_http_ready gauge' \
        "forge_tangled_knot_public_http_ready $public_http_ready" \
        '# HELP forge_tangled_knot_owner_matches Whether the public owner endpoint returns the declared DID.' \
        '# TYPE forge_tangled_knot_owner_matches gauge' \
        "forge_tangled_knot_owner_matches $owner_matches" \
        '# HELP forge_tangled_knot_repositories Number of repository directories on this Knot.' \
        '# TYPE forge_tangled_knot_repositories gauge' \
        "forge_tangled_knot_repositories $repository_count" \
        '# HELP forge_tangled_knot_state_bytes Logical bytes occupied by Knot state.' \
        '# TYPE forge_tangled_knot_state_bytes gauge' \
        "forge_tangled_knot_state_bytes $state_bytes" \
        '# HELP forge_tangled_knot_last_scan_timestamp_seconds Unix timestamp of the last Knot metrics scan.' \
        '# TYPE forge_tangled_knot_last_scan_timestamp_seconds gauge' \
        "forge_tangled_knot_last_scan_timestamp_seconds $(date +%s)" \
        > "$temporary"

      chmod 0644 "$temporary"
      mv --force -- "$temporary" "$target"
    '';
  };
in
{
  imports = [ inputs.tangled.nixosModules.knot ];

  services = {
    tangled.knot = {
      enable = true;
      appviewEndpoint = "https://tangled.org";
      openFirewall = true;
      inherit stateDir;
      repo.scanPath = repositoryDir;
      git = {
        # The upstream module emits this value as a systemd Environment=
        # assignment, so keep it free of whitespace.
        userName = "deCort.tech";
        userEmail = "noreply@decort.tech";
      };
      motd = "Tangled Knot operated by deCort.tech.\n";
      server = {
        hostname = hostname;
        owner = ownerDid;
        listenAddr = publicListenAddress;
        internalListenAddr = internalListenAddress;
        dev = false;
        logDids = false;
        secureMode = true;
      };
    };

    nginx = {
      recommendedProxySettings = true;
      virtualHosts.${hostname} = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://${publicListenAddress}";
          proxyWebsockets = true;
          extraConfig = ''
            client_max_body_size 100m;
            proxy_read_timeout 300s;
            add_header X-Content-Type-Options nosniff always;
          '';
        };
      };
    };
  };

  systemd = {
    services = {
      knot = {
        # The upstream migration step may leave SQLite sidecar files owned by
        # root on the first start. Normalize the complete database set before
        # the service drops privileges to the git user.
        preStart = lib.mkAfter ''
          for sqliteFile in \
            "${databaseFile}" \
            "${databaseFile}-shm" \
            "${databaseFile}-wal"; do
            if [[ -e "$sqliteFile" ]]; then
              ${pkgs.coreutils}/bin/chown git:git "$sqliteFile"
            fi
          done
        '';
        serviceConfig = {
          RestartSec = "5s";
          LogRateLimitIntervalSec = "30s";
          LogRateLimitBurst = 500;
          MemoryHigh = "2G";
          MemoryMax = "4G";
          TasksMax = 512;
          LimitNOFILE = 65536;
          UMask = "0027";
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateTmp = true;
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectSystem = "strict";
          ReadWritePaths = [ stateDir ];
          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
            "AF_UNIX"
          ];
          RestrictNamespaces = true;
          LockPersonality = true;
          SystemCallArchitectures = "native";
        };
      };

      forge-tangled-knot-metrics = {
        description = "Collect Forge Tangled Knot metrics";
        wants = [ "network-online.target" ];
        after = [
          "network-online.target"
          "knot.service"
          "nginx.service"
        ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = lib.getExe knotMetrics;
          User = "root";
          Group = "root";
          UMask = "0022";
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateTmp = true;
          ProtectHome = true;
          ProtectSystem = "strict";
          ReadOnlyPaths = [ stateDir ];
          ReadWritePaths = [ metricDirectory ];
          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
            "AF_NETLINK"
            "AF_UNIX"
          ];
        };
      };
    };

    timers.forge-tangled-knot-metrics = {
      description = "Schedule Forge Tangled Knot metrics collection";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "3m";
        OnUnitActiveSec = "5m";
        Unit = "forge-tangled-knot-metrics.service";
      };
    };
  };
}
