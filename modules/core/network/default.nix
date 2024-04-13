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
        "Unifi" = { psk = "@PSK_unifi@"; };
      };
    };
   
    networking.networkmanager = {
      enable = true;
      insertNameservers = [ "1.1.1.1" "1.0.0.1" ];
      wifi = {
        backend = "iwd";
      };
    };

    age.secrets."secrets/network/wireless.age" = {
      file = ../../../secrets/network/wireless.age;
    };
  };
}
