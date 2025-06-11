{
  config,
  lib,
  pkgs,
  ...
}: {
  options.dc-tec.graphical.swaync = {
    enable = lib.mkEnableOption "Enable swaync";
  };

  config = lib.mkIf config.dc-tec.graphical.swaync.enable {
    home-manager.users.roelc = {
      home.packages = [pkgs.libnotify];
      services.swaync = {
        enable = true;

        ## https://github.com/Frost-Phoenix/nixos-config/blob/4d75ca005a820672a43db9db66949bd33f8fbe9c/modules/home/swaync/config.json
        settings = {
          positionX = "right";
          positionY = "top";
          layer = "overlay";
          layer-shell = true;
          cssPriority = "application";
          control-center-margin-top = 6;
          control-center-marging-bottom = 6;
          control-center-margin-left = 6;
          control-center-margin-right = 6;
          notification-icon-size = 64;
          notification-body-image-height = 128;
          notification-body-image-width = 200;
          notification-2fa-action = true;
          timeout = 10;
          timeout-low = 5;
          timeout-critical = 0;
          fit-to-screen = true;
          control-center-width = 400;
          control-center-height = 650;
          notification-window-width = 350;
          keyboard-shortcuts = true;
          image-visibility = "when-available";
          transition-time = 200;
          hide-on-clear = false;
          hide-on-action = true;
          script-fail-notify = true;
          widgets = [
            "title"
            "menubar#desktop"
            "volume"
            "backlight#mobile"
            "mpris"
            "dnd"
            "notifications"
          ];
          widget-config = {
            title = {
              text = "Control Center";
              clear-all-buttons = true;
              botton-text = " Clear Everything ";
            };
            "menubar#desktop" = {
              "menu#screenshot" = {
                label = "󰄀 ";
                position = "left";
                actions = [
                  {
                    label = "  Full Screen";
                    action = "";
                  }
                  {
                    label = "  Area";
                    action = "";
                  }
                ];
              };
              "menu#record" = {
                label = " ";
                position = "left";
                actions = [
                  {
                    label = "  Record Full Screen";
                    command = "";
                  }
                  {
                    label = "󰩭 Record Area";
                    command = "";
                  }
                  {
                    label = "󰵸 Record GIF";
                    command = "";
                  }
                  {
                    label = " stop Recording";
                    command = "";
                  }
                ];
              };
              "menu#power-buttons" = {
                label = " ";
                position = "left";
                actions = [
                  {
                    label = " Lock Session";
                    command = "swaylock";
                  }
                  {
                    label = "  Reboot";
                    command = "systemctl reboot";
                  }
                  {
                    label = "  Shutdown";
                    command = "systemctl poweroff";
                  }
                ];
              };
            };
            "backlight#mobile" = {
              label = " ";
              device = "panel";
            };
            volume = {
              label = "  ";
              expand-button-label = "";
              colapse-button-label = "";
              show-per-app = true;
              show-per-app-label = false;
            };
            dnd = {
              text = " Silence";
            };
            mpris = {
              iamge-size = 85;
              image-radius = 5;
            };
          };
        };
      };
    };
  };
}
