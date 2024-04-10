{ config, lib, pkgs, ... }: {

  options.dc-tec.graphical.hyprland = {
    enable = lib.mkEnableOption "hyprlandwm";
    top-bar = lib.mkOption {
      default = { };
      type = lib.types.attrs;
    };

    status-configuration.extraConfig = lib.mkOption {
      default = "";
      type = lib.types.lines;
    };
  };
  config = lib.mkIf config.dc-tec.graphical.hyprland.enable {
    services.dbus.packages = with pkgs; [ dconf ];
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [ xdg-desktop-portal-gtk xdg-desktop-portal-hyprland ];
    };

    environment.variables = { XDG_SESSION_TYPE = "wayland"; };

    home-manager.users.roelc = { pkgs, ... }: {
      home.packages = with pkgs; [ wl-clipboard ];
    
      services = {
        cliphist.enable = true;
      };

      wayland.windowManager.hyprland = {
        enable = true;   
      };
    };
  };
}
