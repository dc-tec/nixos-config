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
          monospace = [ "0xProto Nerd Font" ];
          sansSerif = [ "0xProto Nerd Font" ];
          serif = [ "0xProto Nerd Font" ];
        };
      };
      packages = with pkgs; [
        nerd-fonts._0xproto
      ];
    };

    programs.dconf.enable = true;

    home-manager.users.roelc =
      { pkgs, ... }:
      {
        catppuccin = {
          pointerCursor = {
            enable = true;
            accent = "dark";
            flavor = "macchiato";
          };
        };

        gtk = {
          enable = true;
          gtk2.extraConfig = "gtk-application-prefer-dark-theme = true;";
          gtk3.extraConfig.gtk-application-prefer-dark-theme = true;

          font = {
            name = "0xProto Nerd Font";
            size = 10;
          };

          catppuccin = {
            flavor = "macchiato";
            accent = "peach";
            size = "compact";
            #icon = {
            #  enable = true;
            #  flavor = "macchiato";
            #  accent = "peach";
            #};
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
