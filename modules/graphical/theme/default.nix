{
  config,
  lib,
  pkgs,
  ...
}: {
  options.dc-tec.graphical.theme = {
    enable = lib.mkOption {
      default = true;
    };
  };

  config = lib.mkIf config.dc-tec.graphical.theme.enable {
    fonts = {
      enableDefaultPackages = true;
      fontDir = {
        enable = true;
      };
      fontconfig = {
        enable = true;
        defaultFonts = {
          monospace = ["Iosevka Nerd Font"];
          sansSerif = ["Iosevka Nerd Font"];
          serif = ["Iosevka Nerd Font"];
        };
      };
      packages = with pkgs; [
        (nerdfonts.override {fonts = ["Iosevka"];})
      ];
    };

    programs.dconf.enable = true;

    home-manager.users.roelc = {pkgs, ...}: {
      gtk = {
        enable = true;
        font = {
          name = "Iosevka Nerd Font";
          size = 10;
        };
      };

      qt = {
        enable = true;
        platformTheme = "gtk";
      };

      programs.kitty = {
        catppuccin.enable = true;
        font = {
          name = "Iosevka Nerd Font";
          size = 10;
        };
        settings = {
          disable_ligatures = "cursor";

          # Font config
          font_family = "Iosevka Nerd Font";
        };
      };
    };
  };
}
