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