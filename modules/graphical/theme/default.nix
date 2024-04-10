{ config, lib, pkgs, ... }: {

  config = {
    
    fonts = {
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
        settings = {
          font_family = "0xProto";
          font_size = 10;
          disable_ligatures = "cursor";
        };
      };
    };    
  };
}
