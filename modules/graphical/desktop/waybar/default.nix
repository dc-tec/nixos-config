{
  config,
  lib,
  ...
}: {
  options.dc-tec.graphical.waybar = {
    enable = lib.mkEnableOption "Waybar Status Bar";
  };

  config = lib.mkIf config.dc-tec.graphical.waybar.enable {
    home-manager.users.roelc = {pkgs, ...}: {
      programs.waybar = {
        enable = true;
        systemd.enable = true;
        settings = [
          {
            layer = "top";
            position = "top";
            output = [
              "eDP-1"
              "HDMI-A-1"
              "DP-2"
            ];
            modules-left = ["hyprland/workspaces"];
            modules-center = ["hyprland/window"];
            modules-right = ["backlight" "battery" "clock" "tray" "custom/lock" "custom/power"];

            "hyprland/workspaces" = {
              disable-scroll = true;
              sort-by-name = false;
              all-outputs = true;
              persistent-workspaces = {
                "Home" = [];
                "2" = [];
                "3" = [];
                "4" = [];
                "5" = [];
                "6" = [];
                "7" = [];
                "8" = [];
                "9" = [];
                "0" = [];
              };
            };

            "tray" = {
              icon-size = 21;
              spacing = 10;
            };

            "clock" = {
              timezone = "Europe/Amsterdam";
              tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
              format-alt = "  {:%d/%m/%Y}";
              format = "  {:%H:%M}";
            };

            "backlight" = {
              device = "intel_backlight";
              format = "{icon}";
              format-icons = ["" "" "" "" "" "" "" "" ""];
            };

            "battery" = {
              states = {
                warning = 30;
                critical = 15;
              };
              format = "{icon}";
              format-charging = "󰂄";
              format-plugged = "󱟢";
              format-alt = "{icon}";
              format-icons = ["󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
            };

            "custom/lock" = {
              tooltip = false;
              on-click = "${pkgs.hyprlock}/bin/hyprlock";
              format = " ";
            };

            "custom/power" = {
              tooltip = false;
              on-click = "${pkgs.wlogout}/bin/wlogout &";
              format = " ";
            };
          }
        ];

        style = ''
          * {
            font-family: Iosevka Nerd Font;
            font-size: 18px;
            min-height: 0;
          }

          #waybar {
            background: transparent;
            color: @text;
            margin: 5px 5px;
          }

          #workspaces {
            border-radius: 1rem;
            margin: 5px;
            background-color: @surface0;
            margin-left: 1rem;
          }

          #workspaces button {
            color: @lavender;
            border-radius: 1rem;
            padding: 0.4rem;
          }

          #workspaces button.active {
            color: @peach;
            border-radius: 1rem;
          }

          #workspaces button:hover {
            color: @peach;
            border-radius: 1rem;
          }

          #custom-music,
          #tray,
          #backlight,
          #clock,
          #battery,
          #custom-lock,
          #custom-power {
            background-color: @surface0;
            padding: 0.5rem 1rem;
            margin: 5px 0;
          }

          #clock {
            color: @blue;
            border-radius: 0px 1rem 1rem 0px;
            margin-right: 1rem;
          }

          #battery {
            color: @green;
          }

          #battery.charging {
            color: @green;
          }

          #battery.warning:not(.charging) {
            color: @red;
          }

          #backlight {
            color: @yellow;
          }

          #backlight {
              border-radius: 1rem 0px 0px 1rem;
          }

          #custom-music {
            color: @mauve;
            border-radius: 1rem;
          }

          #custom-lock {
              border-radius: 1rem 0px 0px 1rem;
              color: @lavender;
          }

          #custom-power {
              margin-right: 1rem;
              border-radius: 0px 1rem 1rem 0px;
              color: @red;
          }

          #tray {
            margin-right: 1rem;
            border-radius: 1rem;
          }

          @define-color rosewater #f4dbd6;
          @define-color flamingo #f0c6c6;
          @define-color pink #f5bde6;
          @define-color mauve #c6a0f6;
          @define-color red #ed8796;
          @define-color maroon #ee99a0;
          @define-color peach #f5a97f;
          @define-color yellow #eed49f;
          @define-color green #a6da95;
          @define-color teal #8bd5ca;
          @define-color sky #91d7e3;
          @define-color sapphire #7dc4e4;
          @define-color blue #8aadf4;
          @define-color lavender #b7bdf8;
          @define-color text #cad3f5;
          @define-color subtext1 #b8c0e0;
          @define-color subtext0 #a5adcb;
          @define-color overlay2 #939ab7;
          @define-color overlay1 #8087a2;
          @define-color overlay0 #6e738d;
          @define-color surface2 #5b6078;
          @define-color surface1 #494d64;
          @define-color surface0 #363a4f;
          @define-color base #24273a;
          @define-color mantle #1e2030;
          @define-color crust #181926;
        '';
      };
    };
  };
}
