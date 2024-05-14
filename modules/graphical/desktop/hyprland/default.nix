{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  options.dc-tec.graphical.hyprland = {
    enable = lib.mkEnableOption "hyprlandwm";
  };

  config = lib.mkIf config.dc-tec.graphical.hyprland.enable {
    environment.systemPackages = [
      pkgs.wl-clipboard
    ];

    nix.settings = {
      substituters = ["https://hyprland.cachix.org"];
      trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
    };

    services.dbus.packages = with pkgs; [dconf];

    services = {
      xserver = {
        videoDrivers = ["nvidia"];
      };
      displayManager = {
        sddm = {
          enable = true;
          wayland = {
            enable = true;
          };
          settings = {
            Wayland = {
              SessionDir = "${inputs.hyprland.packages.${pkgs.system}.hyprland}/share/wayland-sessions";
            };
          };
        };
      };
    };

    home-manager.users.roelc = {pkgs, ...}: {
      home.packages = with pkgs; [
        qt5.qtwayland
        qt6.qtwayland
      ];

      services = {
        cliphist = {
          enable = true;
        };
      };

      wayland.windowManager.hyprland = {
        enable = true;
        catppuccin.enable = true;
        xwayland = {
          enable = true;
        };

        package = inputs.hyprland.packages.${pkgs.system}.hyprland;

        settings = {
          "$terminal" = "kitty";
          "$mod" = "SUPER";

          monitor = [
            # "eDP-1, 1920x1080, 0x0, 1"
            ",prefered,auto,1"
          ];

          xwayland = {
            force_zero_scaling = true;
          };

          general = {
            gaps_in = 4;
            gaps_out = 6;
            border_size = 2;
            layout = "dwindle";
            allow_tearing = false;
          };

          input = {
            kb_layout = "us";
            follow_mouse = true;
            touchpad = {
              natural_scroll = true;
            };
            accel_profile = "flat";
            sensitivity = 0;
          };

          decoration = {
            rounding = 2;
            active_opacity = 0.9;
            inactive_opacity = 0.8;
            fullscreen_opacity = 0.9;
            blur = {
              enabled = true;
              size = 3;
              passes = 1;
              ignore_opacity = false;
            };
          };

          animations = {
            enabled = true;
            bezier = "myBezier, 0.05, 0.9, 0.1, 1.0";
            animation = [
              "windows, 1, 7, myBezier"
              "windowsOut, 1, 7, default, popin 80%"
              "border, 1, 10, default"
              "borderangle, 1, 8, default"
              "fade, 1, 7, default"
              "workspaces, 1, 6, default"
            ];
          };

          dwindle = {
            pseudotile = true;
            preserve_split = true;
            no_gaps_when_only = 0;
          };

          master = {
            new_is_master = true;
          };

          misc = {
            disable_hyprland_logo = true;
            disable_splash_rendering = true;
          };

          bind = [
            # General
            "$mod, return, exec, $terminal"
            "$mod SHIFT, q, killactive"
            "$mod SHIFT, e, exit"
            "$mod SHIFT, l, exec, ${pkgs.hyprlock}/bin/hyprlock"

            # Screen focus
            "$mod, v, togglefloating"
            "$mod, u, focusurgentorlast"
            "$mod, tab, focuscurrentorlast"
            "$mod, f, fullscreen"

            # Screen resize
            "$mod CTRL, h, resizeactive, -20 0"
            "$mod CTRL, l, resizeactive, 20 0"
            "$mod CTRL, k, resizeactive, 0 -20"
            "$mod CTRL, j, resizeactive, 0 20"

            # Workspaces
            "$mod, 1, workspace, 1"
            "$mod, 2, workspace, 2"
            "$mod, 3, workspace, 3"
            "$mod, 4, workspace, 4"
            "$mod, 5, workspace, 5"
            "$mod, 6, workspace, 6"
            "$mod, 7, workspace, 7"
            "$mod, 8, workspace, 8"
            "$mod, 9, workspace, 9"
            "$mod, 0, workspace, 10"

            # Move to workspaces
            "$mod SHIFT, 1, movetoworkspace,1"
            "$mod SHIFT, 2, movetoworkspace,2"
            "$mod SHIFT, 3, movetoworkspace,3"
            "$mod SHIFT, 4, movetoworkspace,4"
            "$mod SHIFT, 5, movetoworkspace,5"
            "$mod SHIFT, 6, movetoworkspace,6"
            "$mod SHIFT, 7, movetoworkspace,7"
            "$mod SHIFT, 8, movetoworkspace,8"
            "$mod SHIFT, 9, movetoworkspace,9"
            "$mod SHIFT, 0, movetoworkspace,10"

            # Navigation
            "$mod, h, movefocus, l"
            "$mod, l, movefocus, r"
            "$mod, k, movefocus, u"
            "$mod, j, movefocus, d"

            # Applications
            "$mod ALT, f, exec, ${pkgs.firefox}/bin/firefox"
            "$mod ALT, e, exec, $terminal --hold -e ${pkgs.yazi}/bin/yazi"
            "$mod ALT, o, exec, ${pkgs.obsidian}/bin/obsidian"
            "$mod, r, exec, ${pkgs.rofi}/bin/rofi -modes drun -show drun"
          ];

          bindm = [
            "$mod, mouse:272, movewindow"
            "$mod, mouse:273, resizewindow"
          ];

          env = [
            "NIXOS_OZONE_WL,1"
            "_JAVA_AWT_WM_NONREPARENTING,1"
            "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
            "QT_QPA_PLATFORM,wayland"
            "SDL_VIDEODRIVER,wayland"
            "GDK_BACKEND,wayland"
            "LIBVA_DRIVER_NAME,nvidia"
            "XDG_SESSION_TYPE,wayland"
            "XDG_SESSION_DESKTOP,Hyprland"
            "XDG_CURRENT_DESKTOP,Hyprland"
            "GBM_BACKEND,nvidia-drm"
            "__GLX_VENDOR_LIBRARY_NAME,nvidia"
          ];
          exec-once = [
            "${pkgs.hyprpaper}/bin/hyprpaper"
            "${pkgs.wl-clipboard}/bin/wl-paste --type text --watch cliphist store"
            "${pkgs.wl-clipboard}/bin/wl-paste --type image --watch cliphist store"
            "eval $(gnome-keyring-daemon --start --components=secrets,ssh,gpg,pkcs11)"
            "export SSH_AUTH_SOCK"
            "${pkgs.plasma5Packages.polkit-kde-agent}/libexec/polkit-kde-authentication-agent-1"
          ];
        };
        systemd = {
          enable = true;
        };
      };
    };
  };
}
