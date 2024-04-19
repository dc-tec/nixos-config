{
  config,
  lib,
  pkgs,
  ...
}: {
  options.dc-tec.graphical.hyprpaper = {
    enable = lib.mkEnableOption "hyprpaper";
  };

  config = lib.mkIf config.dc-tec.graphical.hyprpaper.enable {
    home-manager.users.roelc = {
      home.file.".config/hypr/hyprpaper.conf".text = ''
        preload = ${/. + ../_assets/wallpaper.jpg}
        wallpaper = ,${/. + ../_assets/wallpaper.jpg}
      '';
    };
  };
}
