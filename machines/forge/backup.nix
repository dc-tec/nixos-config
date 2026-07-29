{
  lib,
  pkgs,
  ...
}:
{
  services.restic.backups.forge-state = {
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

    dynamicFilesFrom = ''
      printf '%s\n' /var/lib/wireguard/forge.key
      ${lib.getExe' pkgs.findutils "find"} /etc/ssh \
        -maxdepth 1 \
        -type f \
        -name 'ssh_host_*' \
        -print
    '';

    extraOptions = [ "rclone.program=${lib.getExe pkgs.rclone}" ];

    # Keep scheduling and retention operator-driven for the next backup slice.
    initialize = false;
    timerConfig = null;
    pruneOpts = [ ];
    checkOpts = [ ];
  };

  systemd.tmpfiles.rules = [ "d /var/lib/forge-secrets 0700 root root -" ];
}
