{
  config,
  lib,
  ...
}: {
  options.dc-tec.graphical.hyprpaper = {
    enable = lib.mkEnableOption "hyprpaper";
  };

  config = lib.mkIf config.dc-tec.graphical.hyprpaper.enable {
    home-manager.users.${config.dc-tec.user.name} = {
      home.file.".config/hypr/hyprpaper.conf".text = ''
        preload = ${/. + _assets/wallpaper.jpg}
        wallpaper = ,${/. + _assets/wallpaper.jpg}
        splash = false
      '';
    };
  };
}
