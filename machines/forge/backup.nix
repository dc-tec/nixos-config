{
  lib,
  pkgs,
  ...
}:
let
  dedibackup = {
    repository = "rclone:dedibackup:forge/restic";
    passwordFile = "/var/lib/forge-secrets/restic-password";

    rcloneConfig = {
      type = "ftp";
      host = "dedibackup-dc3.online.net";
      user = "auto";

      # Dedibackup autologin uses an empty password. rclone still expects the
      # configured value to use its reversible obscured representation.
      pass = "XVcpoa8UoSlGJwF1tSdMng";

      # Dedibackup does not implement EPSV and returns a dedicated data host
      # in its PASV response.
      disable_epsv = true;
    };

    extraOptions = [ "rclone.program=${lib.getExe pkgs.rclone}" ];
  };
in
{
  services.restic.backups = {
    forge-state = dedibackup // {
      dynamicFilesFrom = ''
        printf '%s\n' /var/lib/wireguard/forge.key
        if [ -f /var/lib/forge-secrets/nix-cache-private-key ]; then
          printf '%s\n' /var/lib/forge-secrets/nix-cache-private-key
        fi
        ${lib.getExe' pkgs.findutils "find"} /etc/ssh \
          -maxdepth 1 \
          -type f \
          -name 'ssh_host_*' \
          -print
      '';

      initialize = false;
      timerConfig = {
        OnCalendar = "*-*-* 03:00:00";
        RandomizedDelaySec = "30m";
        Persistent = true;
      };
    };

    forge-maintenance = dedibackup // {
      paths = [ ];
      createWrapper = false;
      pruneOpts = [
        "--keep-daily 14"
        "--keep-weekly 8"
        "--keep-monthly 6"
      ];
      checkOpts = [ "--read-data" ];
      timerConfig = {
        OnCalendar = "Sun *-*-* 05:30:00";
        RandomizedDelaySec = "30m";
        Persistent = true;
      };
    };
  };

  systemd.tmpfiles.rules = [ "d /var/lib/forge-secrets 0700 root root -" ];
}
