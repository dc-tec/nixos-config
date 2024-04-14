{ config, lib, pkgs, ... }: {

  options.dc-tec.graphical.hyprland = {
    enable = lib.mkEnableOption "hyprlandwm";
    top-bar = lib.mkOption {
      default = { };
      type = lib.types.attrs;
    };
  };

  config = lib.mkIf config.dc-tec.graphical.hyprland.enable {
    services.dbus.packages = with pkgs; [ dconf ];

    xdg = {
      portal = {
        enable = true;
        extraPortals = with pkgs; [ xdg-desktop-portal-gtk xdg-desktop-portal-hyprland ];
      };
    };

    environment.variables = { XDG_SESSION_TYPE = "wayland"; };

    home-manager.users.roelc = { pkgs, ... }: {
      home.packages = with pkgs; [ 
        waybar
        swaybg
        swayidle
        swaylock
        wlogout
        wl-clipboard
        hyprpicker
        hyprshot
        grim
        slurp
        mako
      ];
    
      services = {
        cliphist.enable = true;
      };

      wayland.windowManager.hyprland = {
        enable = true;
        settings = {
          env = [
            "NIXOS_OZONE_WL,1" # for any ozone-based browser & electron apps to run on wayland

            # misc
            "_JAVA_AWT_WM_NONREPARENTING,1"
            "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
            "QT_QPA_PLATFORM,wayland"
            "SDL_VIDEODRIVER,wayland"
            "GDK_BACKEND,wayland"            

            # for hyprland with nvidia gpu, ref https://wiki.hyprland.org/Nvidia/
            "LIBVA_DRIVER_NAME,nvidia"
            "XDG_SESSION_TYPE,wayland"
            "GBM_BACKEND,nvidia-drm"
            "__GLX_VENDOR_LIBRARY_NAME,nvidia"
      
            # fix https://github.com/hyprwm/Hyprland/issues/1520
            "WLR_NO_HARDWARE_CURSORS,1"            
          ];
        };
        extraConfig = builtins.readFile ./config/hyprland.conf;
        systemd.enable = true;
      };
    };
  };
}
