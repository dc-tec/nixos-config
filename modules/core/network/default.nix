{ config, lib, ... }: {

  options.dc-tec.core.wireless.enable = lib.mkEnableOption "wireless";
 
  config = lib.mkIf config.dc-tec.core.wireless.enable {
    networking.wireless = {
      iwd = {
	enable = true;
        settings = {
          Settings = {
            AutoConnect = true;
          };
        };
      };
      interfaces = [ "wlan0" ];
      environmentFile = config.age.secrets."secrets/network/wireless.age".path;
      networks = {
        "Unifi (AC)" = { psk = "@PSK_unifi@"; };
      };
    };
   
    networking.interfaces = {
      wlan0 = {
        useDHCP = true;
      };
    };
 
    networking.networkmanager = {
      wifi = {
        backend = "iwd";
      };
    };

    age.secrets."secrets/network/wireless.age" = {
      file = ../../../secrets/network/wireless.age;
    };
  };
}
