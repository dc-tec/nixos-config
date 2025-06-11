{
  config,
  lib,
  ...
}:
{
  options.dc-tec.core.wireless.enable = lib.mkEnableOption "wireless";

  config = lib.mkIf config.dc-tec.core.wireless.enable {
    networking.wireless = {
      enable = true;
      secretsFile = config.sops.secrets.wireless.path;
      networks = {
        "@home_uuid@" = {
          pskRaw = "ext:home_psk";
        };
      };
    };
    systemd.services."enable-wifi-on-boot" = {
      description = "Enable Wifi during boot";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "/run/current-system/sw/bin/rfkill unblock all";
        Type = "oneshot";
      };
    };
  };
}
