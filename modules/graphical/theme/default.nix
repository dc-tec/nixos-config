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
          monospace = ["0xProto Nerd Font"];
          sansSerif = ["0xProto Nerd Font"];
          serif = ["0xProto Nerd Font"];
        };
      };
      packages = with pkgs; [
        (nerdfonts.override {fonts = ["0xProto"];})
      ];
    };

    programs.dconf.enable = true;

    home-manager.users.roelc = {pkgs, ...}: {
      gtk = {
        enable = true;
        gtk2.extraConfig = "gtk-application-prefer-dark-theme = true;";
        gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
        catppuccin = {
          enable = true;
          accent = "maroon";
          cursor = {
            enable = false;
            accent = "peach";
          };
        };

        font = {
          name = "0xProto Nerd Font";
          size = 10;
        };
      };

      qt = {
        enable = true;
        platformTheme.name = "gtk";
      };

      programs.kitty = {
        catppuccin.enable = true;
        font = {
          name = "0xProto Nerd Font";
          size = 10;
        };
        settings = {
          disable_ligatures = "always";

          # Font config
          font_family = "0xProto Nerd Font";
        };
      };
    };
  };
}
