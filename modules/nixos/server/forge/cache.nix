{
  lib,
  pkgs,
  publicKeys,
  ...
}:
let
  cacheRoot = "/cache/nix";
  cacheKeyFile = "/var/lib/forge-secrets/nix-cache-private-key";
  metricDirectory = "/var/lib/prometheus-node-exporter-text-files";
  cachePublicKey = publicKeys.nixCache.forge;

  cacheStore =
    "file://${cacheRoot}"
    + "?compression=zstd"
    + "&compression-level=8"
    + "&parallel-compression=true"
    + "&secret-key=${cacheKeyFile}";

  cacheInfo = pkgs.writeText "forge-nix-cache-info" ''
    StoreDir: /nix/store
    WantMassQuery: 0
    Priority: 30
  '';

  cacheMetrics = pkgs.writeShellApplication {
    name = "forge-cache-metrics";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.curl
      pkgs.findutils
    ];
    text = ''
      target="${metricDirectory}/forge_nix_cache.prom"
      temporary="$target.$$"
      trap 'rm -f -- "$temporary"' EXIT

      if [[ -s "${cacheKeyFile}" ]]; then
        signing_key_present=1
      else
        signing_key_present=0
      fi

      if curl --fail --silent --show-error --head --max-time 10 \
        https://cache.decort.tech/nix-cache-info >/dev/null; then
        http_up=1
      else
        http_up=0
      fi

      narinfo_count="$(find "${cacheRoot}" -maxdepth 1 -type f -name '*.narinfo' -printf . | wc -c)"
      cache_bytes="$(du --summarize --bytes "${cacheRoot}" | cut --fields=1)"

      printf '%s\n' \
        '# HELP forge_nix_cache_http_up Whether the public binary-cache metadata endpoint is reachable.' \
        '# TYPE forge_nix_cache_http_up gauge' \
        "forge_nix_cache_http_up $http_up" \
        '# HELP forge_nix_cache_signing_key_present Whether the private binary-cache signing key is provisioned.' \
        '# TYPE forge_nix_cache_signing_key_present gauge' \
        "forge_nix_cache_signing_key_present $signing_key_present" \
        '# HELP forge_nix_cache_paths Number of store-path metadata files in the binary cache.' \
        '# TYPE forge_nix_cache_paths gauge' \
        "forge_nix_cache_paths $narinfo_count" \
        '# HELP forge_nix_cache_bytes Logical bytes occupied by the binary-cache directory.' \
        '# TYPE forge_nix_cache_bytes gauge' \
        "forge_nix_cache_bytes $cache_bytes" \
        '# HELP forge_nix_cache_last_scan_timestamp_seconds Unix timestamp of the last cache metrics scan.' \
        '# TYPE forge_nix_cache_last_scan_timestamp_seconds gauge' \
        "forge_nix_cache_last_scan_timestamp_seconds $(date +%s)" \
        > "$temporary"

      chmod 0644 "$temporary"
      mv --force -- "$temporary" "$target"
    '';
  };

  cachePublish = pkgs.writeShellApplication {
    name = "forge-cache-publish";
    runtimeInputs = [
      pkgs.nix
      pkgs.util-linux
    ];
    text = ''
      if (( EUID != 0 )); then
        echo "forge-cache-publish must run as root" >&2
        exit 1
      fi

      if [[ "$#" -gt 0 && "$1" == "--" ]]; then
        shift
      fi
      if [[ "$#" -eq 0 ]]; then
        echo "usage: forge-cache-publish STORE_PATH..." >&2
        exit 2
      fi
      if ! mountpoint --quiet /cache; then
        echo "/cache is not a mounted filesystem; refusing to publish" >&2
        exit 1
      fi
      if [[ ! -s "${cacheKeyFile}" ]]; then
        echo "the forge binary-cache signing key has not been provisioned" >&2
        exit 1
      fi

      for store_path in "$@"; do
        case "$store_path" in
          /nix/store/*) ;;
          *)
            echo "not a Nix store path: $store_path" >&2
            exit 2
            ;;
        esac
        nix path-info -- "$store_path" >/dev/null
      done

      umask 0022
      nix copy --to '${cacheStore}' -- "$@"
      ${lib.getExe cacheMetrics}
    '';
  };
in
{
  assertions = [
    {
      assertion = lib.hasPrefix "cache.decort.tech-1:" cachePublicKey;
      message = "The forge binary-cache public key has an unexpected identity.";
    }
  ];

  nix.settings = {
    substituters = [ "https://cache.decort.tech?priority=30" ];
    trusted-public-keys = [ cachePublicKey ];
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  security.acme = {
    acceptTerms = true;
    defaults.email = "roel@decort.tech";
  };

  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;

    virtualHosts = {
      "_default" = {
        default = true;
        rejectSSL = true;
        locations."/".return = "444";
      };

      "cache.decort.tech" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          root = cacheRoot;
          extraConfig = ''
            limit_except GET HEAD {
              deny all;
            }
            try_files $uri =404;
            autoindex off;
            add_header X-Content-Type-Options nosniff always;
          '';
        };
      };
    };
  };

  environment.systemPackages = [ cachePublish ];

  systemd = {
    services = {
      forge-cache-initialize = {
        description = "Initialize the native forge binary cache";
        wantedBy = [ "multi-user.target" ];
        before = [ "nginx.service" ];
        unitConfig = {
          ConditionPathIsMountPoint = "/cache";
          RequiresMountsFor = "/cache";
        };
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = pkgs.writeShellScript "forge-cache-initialize" ''
            set -euo pipefail
            ${lib.getExe' pkgs.coreutils "install"} -d -m 0755 -o root -g root ${cacheRoot}
            ${lib.getExe' pkgs.coreutils "install"} -m 0644 -o root -g root ${cacheInfo} \
              ${cacheRoot}/nix-cache-info
          '';
          UMask = "0022";
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateTmp = true;
          ProtectHome = true;
          ProtectSystem = "strict";
          ReadWritePaths = [ cacheRoot ];
        };
      };

      nginx = {
        requires = [ "forge-cache-initialize.service" ];
        after = [ "forge-cache-initialize.service" ];
      };

      forge-cache-metrics = {
        description = "Collect forge binary-cache metrics";
        wants = [ "network-online.target" ];
        after = [
          "network-online.target"
          "nginx.service"
        ];
        unitConfig = {
          ConditionPathIsMountPoint = "/cache";
          RequiresMountsFor = "/cache";
        };
        serviceConfig = {
          Type = "oneshot";
          ExecStart = lib.getExe cacheMetrics;
          User = "root";
          Group = "root";
          UMask = "0022";
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateTmp = true;
          ProtectHome = true;
          ProtectSystem = "strict";
          ReadOnlyPaths = [
            cacheRoot
            "-${cacheKeyFile}"
          ];
          ReadWritePaths = [ metricDirectory ];
          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
          ];
        };
      };
    };

    timers.forge-cache-metrics = {
      description = "Schedule forge binary-cache metrics collection";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "5m";
        OnUnitActiveSec = "5m";
        Unit = "forge-cache-metrics.service";
      };
    };

    tmpfiles.rules = [
      "d ${cacheRoot} 0755 root root -"
    ];
  };
}
