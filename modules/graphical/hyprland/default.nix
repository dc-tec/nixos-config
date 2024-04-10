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
        extraConfig = ''
            monitor=,highres,auto,1

            input {
                kb_layout = us,us
                kb_variant = altgr-intl,colemak_dh
                kb_model =
                kb_options = ctrl:nocaps
                kb_rules =

                follow_mouse = 1

                touchpad {
                    natural_scroll = no
                }

                sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
                accel_profile = adaptive
            }

            general {
                # See https://wiki.hyprland.org/Configuring/Variables/
                gaps_in = 0
                gaps_out = 0

                border_size = 4
                col.active_border = 0xff065fff

                layout = master
            }

            decoration {
                # See https://wiki.hyprland.org/Configuring/Variables/
                rounding = 0
                drop_shadow = false
                blur {
                    enabled = false
                }
            }

            animations {
                # See https://wiki.hyprland.org/Configuring/Animations/
                enabled = yes
                animation=global, 1, .8, default
            }

            master {
                # See https://wiki.hyprland.org/Configuring/Master-Layout/
                orientation = center
                mfact = 0.5
                always_center_master = true
                new_is_master = false
            }

            gestures {
                # See https://wiki.hyprland.org/Configuring/Variables/
                workspace_swipe = off
            }

            misc {
                 disable_hyprland_logo = true
                 disable_splash_rendering = true
                 enable_swallow = true
                 swallow_regex = ^(kitty)$
                 vfr = true
            }

            # Window Rules
            # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
            windowrule = float, ^(launcher)$

          	windowrule = float, title:^(Volume Control)$
           	windowrule = size 33% 480, title:^(Volume Control)$
           	windowrule = move 66% 24, title:^(Volume Control)$

            windowrule = float, title:^(Picture-in-Picture)$|^(Firefox — Sharing Indicator)$|^(About Mozilla Firefox)$
            windowrule = move 0 0, title:^(Firefox — Sharing Indicator)$
            windowrule = idleinhibit fullscreen, firefox

            windowrule = idleinhibit focus, mpv

            # Clipboard manager
            exec-once = wl-paste --type text  --watch cliphist store
            exec-once = wl-paste --type image --watch cliphist store
            bind = SUPER, O, exec, cliphist list | ${pkgs.fuzzel}/bin/fuzzel --dmenu -p "Select item to copy: " --width 120 | cliphist decode | wl-copy

            # Keybindings
            # See https://wiki.hyprland.org/Configuring/Binds/
            bind = SUPER, return, exec, emacsclient -c -e "(shell)"
            bind = SUPER SHIFT, return, exec, kitty --single-instance
            bind = SUPER, Q, killactive,
            bind = SUPER SHIFT, E, exec, hyprctl kill
            bind = SUPER SHIFT, M, exit,
            bind = SUPER, F, fullscreen,
            bind = SUPER, V, togglefloating,
            bind = SUPER, T, pin,
            bind = SUPER, D, exec, ${pkgs.fuzzel}/bin/fuzzel
            bind = SUPER, G, exec, emacsclient -c -e "(org-agenda :arg \"g\")"
            bind = SUPER, Z, exec, hypr-night-toggle

            bind = SUPER, P, exec, env XDG_CURRENT_DESKTOP=sway flameshot gui
            exec-once = env XDG_CURRENT_DESKTOP=sway flameshot

            bind = SUPER, N, layoutmsg, cyclenext
            bind = SUPER, E, layoutmsg, cycleprev
            bind = SUPER, TAB, cyclenext,

            bind = SUPER SHIFT, N, layoutmsg, swapnext
            bind = SUPER SHIFT, E, layoutmsg, swapprev

            bind = SUPER ALT, M, resizeactive, -100 0
            bind = SUPER ALT, N, resizeactive, 0 100
            bind = SUPER ALT, E, resizeactive, 0 -100
            bind = SUPER ALT, I, resizeactive, 100 0

            bind = SUPER ALT SHIFT, M, moveactive, -100 0
            bind = SUPER ALT SHIFT, N, moveactive, 0 100
            bind = SUPER ALT SHIFT, E, moveactive, 0 -100
            bind = SUPER ALT SHIFT, I, moveactive, 100 0

            bind = SUPER,   SPACE, layoutmsg, swapwithmaster master

            # Switch workspaces with super + [0-9]
            bind = SUPER, 1, workspace, 1
            bind = SUPER, 2, workspace, 2
            bind = SUPER, 3, workspace, 3
            bind = SUPER, 4, workspace, 4
            bind = SUPER, 5, workspace, 5
            bind = SUPER, 6, workspace, 6
            bind = SUPER, 7, workspace, 7
            bind = SUPER, 8, workspace, 8
            bind = SUPER, 9, workspace, 9
            bind = SUPER, 0, workspace, 10

            # Move active window to a workspace with super + shift + [0-9]
            bind = SUPER SHIFT, 1, movetoworkspacesilent, 1
            bind = SUPER SHIFT, 2, movetoworkspacesilent, 2
            bind = SUPER SHIFT, 3, movetoworkspacesilent, 3
            bind = SUPER SHIFT, 4, movetoworkspacesilent, 4
            bind = SUPER SHIFT, 5, movetoworkspacesilent, 5
            bind = SUPER SHIFT, 6, movetoworkspacesilent, 6
            bind = SUPER SHIFT, 7, movetoworkspacesilent, 7
            bind = SUPER SHIFT, 8, movetoworkspacesilent, 8
            bind = SUPER SHIFT, 9, movetoworkspacesilent, 9
            bind = SUPER SHIFT, 0, movetoworkspacesilent, 10

            # Master Orientation
            bind = SUPER, RIGHT, layoutmsg, mfact 0.55
            bind = SUPER, RIGHT, layoutmsg, orientationright
            bind = SUPER, UP,    layoutmsg, mfact 0.45
            bind = SUPER, UP,    layoutmsg, orientationcenter

            # Scratchpad
            bind = SUPER,       MINUS, togglespecialworkspace,
            bind = SUPER SHIFT, MINUS, movetoworkspace, special

            # Scroll through existing workspaces with super + scroll
            bind = SUPER, mouse_down, workspace, e+1
            bind = SUPER, mouse_up, workspace, e-1

            # Move/resize windows with super + LMB/RMB and dragging
            bindm = SUPER, mouse:272, movewindow
            bindm = SUPER, mouse:273, resizewindow
        '';   
      };
    };
  };
}
