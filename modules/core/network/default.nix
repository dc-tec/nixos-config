{ config, lib, ... }: {

  options.dc-tec.core.wireless.enable = lib.mkEnableOption "wireless";
 
  config = lib.mkIf config.dc-tec.core.wireless.enable {
    networking.wireless = {
      enable = true;
      environmentFile = config.age.secrets."secrets/network/wireless.age".path;
      networks = {
        "Unifi (AC)" = { psk = "@PSK_unifi@"; };
      };
    };

    age.secrets."secrets/network/wireless.age" = {
      file = ../../../secrets/network/wireless.age;
    };
  };
}
