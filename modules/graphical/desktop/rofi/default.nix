{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.dc-tec.graphical.hyprland.enable {
    home-manager.users.roelc = {
      programs.rofi = {
        enable = true;
        catppuccin = {
          enable = true;
          flavor = "macchiato";
        };
        terminal = "${pkgs.kitty}/bin/kitty";
        plugins = [
          pkgs.rofi-systemd
        ];
        font = "0xProto Nerd Font";
        extraConfig = {
          show-icons = false;
          modi = "window,run,ssh";
          sort = true;
        };
      };
    };
  };
}
