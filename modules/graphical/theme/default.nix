{ config, lib, pkgs, ... }: {

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
          monospace = [ "0xProto" ];
          sansSerif = [ "0xProto" ];
          serif = [ "0xProto" ];  
        };
      };
      packages = with pkgs; [
      	(nerdfonts.override { fonts = [ "0xProto" ]; })
      ];
    };
    
    programs.dconf.enable = true;

    home-manager.users.roelc = { pkgs, ... }: {
      home.packages = [ pkgs.vanilla-dmz ];
    
      dconf = {
        enable = true;
        settings."org/gnome/desktop/interface" = {
          cursor-theme = "Vanilla-DMZ";
        };
      };

      gtk = {
        enable = true;
        font = {
          name = "0xProto";
          size = 10;
        };
        gtk2.extraConfig = ''
          gtk-cursor-theme-name = "Vanilla-DMZ"
          gtk-cursor-theme-size = 0
        '';
        gtk3.extraConfig = {
          gtk-cursor-theme-name = "Vanilla-DMZ";
          gtk-cursor-theme-size = 0;
        };
      };

      qt = {
        enable = true;
        platformTheme = "gtk";
      };

      programs.kitty = {
        font = {
          name = "0xProto";
          size = 9;
        };
        settings = {
          disable_ligatures = "cursor";
     
          # The basic colors
          foreground = "#${config.colorScheme.palette.base05}";
          background = "#${config.colorScheme.palette.base00}";
          selection_foreground = "#${config.colorScheme.palette.base00}";
          selection_background = "#${config.colorScheme.palette.base06}";
          
          # Cursor colors
          cursor = "#${config.colorScheme.palette.base06}";
          cursor_text_color = "#${config.colorScheme.palette.base00}";
          
          # URL underline color when hovering with mouse
          url_color = "#${config.colorScheme.palette.base06}";
          
          # Kitty window border colors
          active_border_color = "#${config.colorScheme.palette.base07}";
          inactive_border_color = "#${config.colorScheme.palette.base04}";
          bell_border_color = "#${config.colorScheme.palette.base0A}";
          
          # Tab bar colors
          active_tab_background = "#${config.colorScheme.palette.base00}";
          active_tab_foreground = "#${config.colorScheme.palette.base05}";
          inactive_tab_background = "#${config.colorScheme.palette.base01}";
          inactive_tab_foreground = "#${config.colorScheme.palette.base04}";
          tab_bar_background = "#${config.colorScheme.palette.base01}";
          
          # Colors for marks (marked text in the terminal)
          mark1_foreground = "#${config.colorScheme.palette.base00}";
          mark1_background = "#${config.colorScheme.palette.base07}";
          mark2_foreground = "#${config.colorScheme.palette.base00}";
          mark2_background = "#${config.colorScheme.palette.base0E}";
          mark3_foreground = "#${config.colorScheme.palette.base00}";
          mark3_background = "#${config.colorScheme.palette.base0D}";

          # The 16 terminal colors
          # black
          color0 = "#${config.colorScheme.palette.base03}";
          color8 = "#${config.colorScheme.palette.base04}";
          # red
          color1 = "#${config.colorScheme.palette.base08}";
          color9 = "#${config.colorScheme.palette.base08}";
          # green
          color2  = "#${config.colorScheme.palette.base0B}";
          color10 = "#${config.colorScheme.palette.base0B}";
          # yellow
          color3 = "#${config.colorScheme.palette.base0A}";
          color11 = "#${config.colorScheme.palette.base0A}";
          # blue
          color4 = "#${config.colorScheme.palette.base0D}";
          color12 = "#${config.colorScheme.palette.base0D}";
          # magenta
          color5 = "#${config.colorScheme.palette.base0E}";
          color13 = "#${config.colorScheme.palette.base0E}";
          # cyan
          color6 = "#${config.colorScheme.palette.base0C}";
          color14 = "#${config.colorScheme.palette.base0C}";
          # white
          color7 = "#${config.colorScheme.palette.base05}";
          color15 = "#${config.colorScheme.palette.base05}";
        };
      };
    };    
  };
}
