{
  config,
  lib,
  ...
}: {
  options.dc-tec.graphical.sound = {
    enable = lib.mkEnableOption "Sound";
  };

  config = lib.mkIf config.dc-tec.graphical.sound.enable {
    security = {
      rtkit.enable = true;
    };

    environment.etc = {
      "wireplumber/bluetooth.lua.d/51-bluez-config.lua".text = ''
        bluez_monitor.properties = {
        	["bluez5.enable-sbc-xq"] = true,
        	["bluez5.enable-msbc"] = true,
        	["bluez5.enable-hw-volume"] = true,
        	["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
        }
      '';
    };

    hardware = {
      bluetooth = {
        enable = true;
        settings = {
          General = {
            Enable = "Control,Gateway,Headset,Media,Sink,Socket,Source";
            MultiProfile = "multiple";
          };
        };
      };
      pulseaudio.enable = false;
    };

    services.pipewire = {
      enable = true;
      audio.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;
      #jack.enable = true;
    };
  };
}
