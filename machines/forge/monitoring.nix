{
  lib,
  pkgs,
  ...
}:
let
  metricDirectory = "/var/lib/prometheus-node-exporter-text-files";

  mkBackupSuccessMetric =
    job:
    pkgs.writeShellScript "forge-backup-${job}-metric" ''
      set -euo pipefail

      target="${metricDirectory}/forge_backup_${job}.prom"
      temporary="$target.$$"
      trap '${lib.getExe' pkgs.coreutils "rm"} -f -- "$temporary"' EXIT

      ${lib.getExe' pkgs.coreutils "printf"} '%s\n' \
        '# HELP forge_backup_last_success_timestamp_seconds Unix timestamp of the last successful forge backup job.' \
        '# TYPE forge_backup_last_success_timestamp_seconds gauge' \
        "forge_backup_last_success_timestamp_seconds{job=\"${job}\"} $(${lib.getExe' pkgs.coreutils "date"} +%s)" \
        > "$temporary"
      ${lib.getExe' pkgs.coreutils "chmod"} 0644 "$temporary"
      ${lib.getExe' pkgs.coreutils "mv"} -f -- "$temporary" "$target"
    '';

  backupInventoryMetric = pkgs.writeShellScript "forge-backup-inventory-metric" ''
    set -euo pipefail

    target="${metricDirectory}/forge_backup_inventory.prom"
    temporary="$target.$$"
    trap '${lib.getExe' pkgs.coreutils "rm"} -f -- "$temporary"' EXIT

    object_count="$(${lib.getExe pkgs.rclone} lsf \
      --config /dev/null \
      --recursive \
      --files-only \
      :ftp:forge/restic \
      --ftp-host dedibackup-dc3.online.net \
      --ftp-user auto \
      --ftp-pass XVcpoa8UoSlGJwF1tSdMng \
      --ftp-disable-epsv \
      | ${lib.getExe pkgs.gawk} 'END { print NR }')"

    ${lib.getExe' pkgs.coreutils "printf"} '%s\n' \
      '# HELP forge_backup_backend_objects Number of objects in the Dedibackup Restic repository.' \
      '# TYPE forge_backup_backend_objects gauge' \
      "forge_backup_backend_objects $object_count" \
      '# HELP forge_backup_inventory_last_success_timestamp_seconds Unix timestamp of the last successful backend inventory.' \
      '# TYPE forge_backup_inventory_last_success_timestamp_seconds gauge' \
      "forge_backup_inventory_last_success_timestamp_seconds $(${lib.getExe' pkgs.coreutils "date"} +%s)" \
      > "$temporary"
    ${lib.getExe' pkgs.coreutils "chmod"} 0644 "$temporary"
    ${lib.getExe' pkgs.coreutils "mv"} -f -- "$temporary" "$target"
  '';

  metricWriterService = {
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      Group = "root";
      UMask = "0022";
      NoNewPrivileges = true;
      PrivateDevices = true;
      PrivateTmp = true;
      ProtectHome = true;
      ProtectSystem = "strict";
      ReadWritePaths = [ metricDirectory ];
    };
  };
in
{
  networking.firewall.interfaces.wg0.allowedTCPPorts = [ 3000 ];

  services = {
    prometheus = {
      enable = true;
      listenAddress = "127.0.0.1";
      port = 9090;
      retentionTime = "30d";
      globalConfig = {
        scrape_interval = "15s";
        evaluation_interval = "15s";
      };
      scrapeConfigs = [
        {
          job_name = "prometheus";
          static_configs = [
            {
              targets = [ "127.0.0.1:9090" ];
              labels.instance = "forge";
            }
          ];
        }
        {
          job_name = "node";
          static_configs = [
            {
              targets = [ "127.0.0.1:9100" ];
              labels.instance = "forge";
            }
          ];
        }
        {
          job_name = "smartctl";
          scrape_interval = "1m";
          static_configs = [
            {
              targets = [ "127.0.0.1:9633" ];
              labels.instance = "forge";
            }
          ];
        }
      ];

      exporters = {
        node = {
          enable = true;
          listenAddress = "127.0.0.1";
          enabledCollectors = [ "systemd" ];
          extraFlags = [ "--collector.textfile.directory=${metricDirectory}" ];
        };
        smartctl = {
          enable = true;
          listenAddress = "127.0.0.1";
          maxInterval = "5m";
        };
      };
    };

    grafana = {
      enable = true;
      openFirewall = false;
      settings = {
        server = {
          http_addr = "10.77.0.1";
          http_port = 3000;
          root_url = "http://10.77.0.1:3000";
        };
        security = {
          disable_initial_admin_creation = true;
          secret_key = "$__file{/var/lib/grafana/secret-key}";
        };
        auth.disable_login_form = true;
        "auth.anonymous" = {
          enabled = true;
          org_name = "Main Org.";
          org_role = "Viewer";
          hide_version = true;
        };
        users = {
          allow_sign_up = false;
          allow_org_create = false;
          default_theme = "system";
        };
        analytics = {
          reporting_enabled = false;
          check_for_updates = false;
          check_for_plugin_updates = false;
          feedback_links_enabled = false;
        };
      };
      provision = {
        enable = true;
        datasources.settings = {
          apiVersion = 1;
          prune = true;
          datasources = [
            {
              name = "Prometheus";
              uid = "prometheus";
              type = "prometheus";
              access = "proxy";
              url = "http://127.0.0.1:9090";
              isDefault = true;
              editable = false;
              jsonData.timeInterval = "15s";
            }
          ];
        };
        dashboards.settings = {
          apiVersion = 1;
          providers = [
            {
              name = "forge";
              type = "file";
              disableDeletion = true;
              editable = false;
              updateIntervalSeconds = 30;
              options.path = ./grafana-dashboards;
            }
          ];
        };
      };
    };
  };

  systemd = {
    services = {
      grafana.preStart = lib.mkBefore ''
        if [ ! -s /var/lib/grafana/secret-key ]; then
          umask 0077
          temporary="/var/lib/grafana/.secret-key.$$"
          trap '${lib.getExe' pkgs.coreutils "rm"} -f -- "$temporary"' EXIT
          ${lib.getExe' pkgs.coreutils "head"} -c 48 /dev/urandom \
            | ${lib.getExe' pkgs.coreutils "base64"} > "$temporary"
          ${lib.getExe' pkgs.coreutils "mv"} -f -- "$temporary" \
            /var/lib/grafana/secret-key
        fi
      '';

      restic-backups-forge-state.unitConfig.OnSuccess = [
        "forge-backup-state-metrics.service"
      ];
      restic-backups-forge-maintenance.unitConfig.OnSuccess = [
        "forge-backup-maintenance-metrics.service"
      ];

      forge-backup-state-metrics = metricWriterService // {
        description = "Record successful forge state backup metric";
        serviceConfig.ExecStart = mkBackupSuccessMetric "state";
      };
      forge-backup-maintenance-metrics = metricWriterService // {
        description = "Record successful forge backup maintenance metric";
        serviceConfig.ExecStart = mkBackupSuccessMetric "maintenance";
      };
      forge-backup-inventory-metrics = metricWriterService // {
        description = "Record forge backup backend inventory metrics";
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];
        serviceConfig = metricWriterService.serviceConfig // {
          ExecStart = backupInventoryMetric;
          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
          ];
        };
      };
    };

    timers.forge-backup-inventory-metrics = {
      description = "Schedule forge backup backend inventory metrics";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*-*-* 04:00:00";
        RandomizedDelaySec = "30m";
        Persistent = true;
      };
    };

    tmpfiles.rules = [ "d ${metricDirectory} 0755 root root -" ];
  };
}
