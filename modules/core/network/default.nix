{ config, lib, ... }: {

  options.dc-tec.core.wireless.enable = lib.mkEnableOption "wireless";
 
  config = lib.mkIf config.dc-tec.core.wireless.enable {
    networking.wireless = {
      enable = true;
      environmentFile = config.age.secrets."secrets/network/wireless.age".path;
      networks = {
        "UniFi" = { psk = "@PSK_unifi@"; };
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

    age.secrets."secrets/network/wireless.age" = {
      file = ../../../secrets/network/wireless.age;
    };
  };
}
