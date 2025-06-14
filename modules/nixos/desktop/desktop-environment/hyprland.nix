{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  options.dc-tec.graphical.hyprland = {
    enable = lib.mkEnableOption "hyprlandwm";
  };

  config = lib.mkIf config.dc-tec.graphical.hyprland.enable {
    environment.systemPackages = with pkgs; [
      wl-clipboard
      slurp
      grim
      catppuccin-sddm.override {
        flavor = config.dc-tec.colorScheme.flavor;
        accent = config.dc-tec.colorScheme.accent;
        font  = config.dc-tec.font;
        fontSize = "12";
        background = "${./_assets/lockscreen.png}";
        loginBackground = true;
      }
    ];

    nix.settings = {
      substituters = [ "https://hyprland.cachix.org" ];
      trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
    };

    services = {
      xserver = {
        videoDrivers = [ "nvidia" ];
      };
      displayManager = {
        sddm = {
          enable = true;
          package = pkgs.kdePackages.sddm;
          wayland = {
            enable = true;
          };
          theme = "catppuccin-macchiato";
          settings = {
            Wayland = {
              SessionDir = "${pkgs.hyprland}/share/wayland-sessions";
            };
          };
          extraPackages = with pkgs.kdePackages; [
            plasma5support
            qtsvg
            qtvirtualkeyboard
          ];
        };
      };
    };

    home-manager.users.${config.dc-tec.user.name} =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          qt5.qtwayland
          qt6.qtwayland
        ];

        services = {
          cliphist = {
            enable = true;
          };
        };

        ## Took some stuff from the end4 dots config @ https://github.com/end-4/dots-hyprland/blob/main/.config/hypr/hyprland/general.conf
        wayland.windowManager.hyprland = {
          enable = true;
          xwayland = {
            enable = true;
          };

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
              gaps_in = 6;
              gaps_out = 6;
              border_size = 2;
              layout = "dwindle";
              allow_tearing = true;
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
              rounding = 15;
              active_opacity = 0.9;
              inactive_opacity = 0.8;
              fullscreen_opacity = 0.9;

              blur = {
                enabled = true;
                xray = true;
                special = false;
                new_optimizations = true;
                size = 14;
                passes = 4;
                brightness = 1;
                noise = 0.01;
                contrast = 1;
                popups = true;
                popups_ignorealpha = 0.6;
                ignore_opacity = false;
              };

              drop_shadow = true;
              shadow_ignore_window = true;
              shadow_range = 20;
              shadow_offset = "0 2";
              shadow_render_power = 4;
            };

            animations = {
              enabled = true;
              bezier = [
                "linear, 0, 0, 1, 1"
                "md3_standard, 0.2, 0, 0, 1"
                "md3_decel, 0.05, 0.7, 0.1, 1"
                "md3_accel, 0.3, 0, 0.8, 0.15"
                "overshot, 0.05, 0.9, 0.1, 1.1"
                "crazyshot, 0.1, 1.5, 0.76, 0.92"
                "hyprnostretch, 0.05, 0.9, 0.1, 1.0"
                "menu_decel, 0.1, 1, 0, 1"
                "menu_accel, 0.38, 0.04, 1, 0.07"
                "easeInOutCirc, 0.85, 0, 0.15, 1"
                "easeOutCirc, 0, 0.55, 0.45, 1"
                "easeOutExpo, 0.16, 1, 0.3, 1"
                "softAcDecel, 0.26, 0.26, 0.15, 1"
                "md2, 0.4, 0, 0.2, 1"
              ];
              animation = [
                "windows, 1, 3, md3_decel, popin 60%"
                "windowsIn, 1, 3, md3_decel, popin 60%"
                "windowsOut, 1, 3, md3_accel, popin 60%"
                "border, 1, 10, default"
                "fade, 1, 3, md3_decel"
                "layersIn, 1, 3, menu_decel, slide"
                "layersOut, 1, 1.6, menu_accel"
                "fadeLayersIn, 1, 2, menu_decel"
                "fadeLayersOut, 1, 4.5, menu_accel"
                "workspaces, 1, 7, menu_decel, slide"
                "specialWorkspace, 1, 3, md3_decel, slidevert"
              ];
            };

            cursor = {
              enable_hyprcursor = true;
            };

            dwindle = {
              pseudotile = true;
              preserve_split = true;
              no_gaps_when_only = 0;
              smart_split = false;
              smart_resizing = false;
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
              "$mod, r, exec, pkill fuzzel || ${pkgs.fuzzel}/bin/fuzzel"
              "$mod ALT, r, exec, pkill anyrun || ${pkgs.anyrun}/bin/anyrun"
              "$mod ALT, n, exec, swaync-client -t -sw"

              # Clipboard
              "$mod ALT, v, exec, pkill fuzzel || cliphist list | fuzzel --no-fuzzy --dmenu | cliphist decode | wl-copy"

              # Screencapture
              "$mod, S, exec, ${pkgs.grim}/bin/grim | wl-copy"
              "$mod SHIFT+ALT, S, exec, ${pkgs.grim}/bin/grim -g \"$(slurp)\" - | ${pkgs.swappy}/bin/swappy -f -"
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
              "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP &"
              "hash dbus-update-activation-environment 2>/dev/null"
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
