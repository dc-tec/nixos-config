{ config, lib, pkgs, ... }: {

  options.dc-tec.graphical.waybar = {
    enable = lib.mkEnableOption "Waybar Status Bar";
  };

  config = lib.mkIf config.dc-tec.graphical.waybar.enable {
    home-manager.users.roelc = { pkgs, ... }: {
      programs.waybar = {
        enable = true;
        settings = [
          {
            layer = "top";
            output = [
              "eDP-1"
              "HDMI-A-1"
            ];
            modules-left = [ "clock" "hyprland/workspaces" ];
            modules-center = [ "hyprland/window" ];
            modules-right = [ "battery" ];

            "hyprland/workspaces" = {
              disable-scroll = true;
              all-outputs = true;
            };

            "clock" = {
              format = "{:%a, %b %d - %H:%M}";
            };
          }       
        ];
      };
    };
  };
}
