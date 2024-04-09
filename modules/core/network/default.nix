{ config, lib, ... }: {

  options.dc-tec.core.network.enable = lib.mkEnableOption "wireless";
 
  config = lib.mkIf options.dc-tec.core.network.enable {
    networking.wireless = {
      enable = true;
      environmentFile = config.age.secrets."networks/wireless.age"l;
      networks = {
        "Unifi (AC)" = { psk = "@PSK_unifi@"; };
    };
  };

    age.secrets."networks/wireless.age" = {
      file = ../../../secrets/networks/wireless.age;
    };
  };
}
