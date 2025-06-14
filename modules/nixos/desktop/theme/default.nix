{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.dc-tec.graphical.theme = {
    enable = lib.mkOption {
      default = true;
      description = "Enable graphical theme configuration including fonts, GTK, and Qt theming";
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
          monospace = [ config.dc-tec.font ];
          sansSerif = [ config.dc-tec.font ];
          serif = [ config.dc-tec.font ];
        };
      };
      packages = with pkgs; [
        nerd-fonts._0xproto
      ];
      # System-wide catppuccin configuration (Linux only)
      # (Removed: catppuccin configuration here was invalid for the fonts module)
    };

    programs.dconf.enable = true;

    home-manager.users.${config.dc-tec.user.name} =
      { pkgs, ... }:
      {
        catppuccin = {
          pointerCursor = {
            enable = true;
            accent = "dark";
            flavor = config.dc-tec.colorScheme.flavor;
          };
        };

        gtk = {
          enable = true;
          gtk2.extraConfig = "gtk-application-prefer-dark-theme = true;";
          gtk3.extraConfig.gtk-application-prefer-dark-theme = true;

          font = {
            name = config.dc-tec.font;
            size = 10;
          };

          catppuccin = {
            flavor = config.dc-tec.colorScheme.flavor;
            accent = config.dc-tec.colorScheme.accent;
            size = "compact";
          };
        };

        qt = {
          enable = true;
          platformTheme.name = "kvantum";
          style.name = "kvantum";
        };
      };
  };
}
