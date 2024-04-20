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
    services.dbus.packages = with pkgs; [dconf];

    xdg = {
      portal = {
        enable = true;
        wlr.enable = true;
        extraPortals = with pkgs; [xdg-desktop-portal-hyprland];
      };
    };

    services = {
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
      services = {
        cliphist.enable = true;
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
            "eDP-1, 1920x1080, 0x0, 1"
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
            "GBM_BACKEND,nvidia-drm"
            "__GLX_VENDOR_LIBRARY_NAME,nvidia"
            "WLR_NO_HARDWARE_CURSORS,1"
            "SSH_AUTH_SOCK,$XDG_RUNTIME_DIR/ssh-agent.socket"
          ];
          exec-once = [
            "${pkgs.hyprpaper}/bin/hyprpaper"
          ];
        };
        systemd = {
          enable = true;
        };
      };
    };
  };
}
