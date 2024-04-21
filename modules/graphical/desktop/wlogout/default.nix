{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.dc-tec.graphical.hyprland.enable {
    home-manager.users.roelc = {pkgs, ...}: {
      programs.wlogout = {
        enable = true;
        layout = [
          {
            label = "lock";
            action = "${pkgs.swaylock}/bin/swaylock";
            text = "Lock";
            keybind = "l";
          }
          {
            label = "reboot";
            action = "systemctl reboot";
            text = "Reboot";
            keybind = "r";
          }
          {
            label = "shutdown";
            action = "systemctl poweroff";
            text = "Shutdown";
            keybind = "s";
          }
          {
            label = "logout";
            action = "hyprctl dispatch exit 0";
            text = "Logout";
            keybind = "e";
          }
          {
            label = "suspend";
            action = "systemctl suspend";
            text = "Suspend";
            keybind = "u";
          }
        ];

        style = ''
          window {
              font-family: monospace;
              font-size: 14pt;
              color: #cdd6f4; /* text */
              background-color: rgba(30, 30, 46, 0.5);
          }

          button {
              background-repeat: no-repeat;
              background-position: center;
              background-size: 25%;
              border: none;
              background-color: rgba(30, 30, 46, 0);
              margin: 5px;
              transition: box-shadow 0.2s ease-in-out, background-color 0.2s ease-in-out;
          }

          button:hover {
              background-color: rgba(49, 50, 68, 0.1);
          }

          button:focus {
              background-color: #cba6f7;
              color: #1e1e2e;
            }

          #lock {
              background-image: url("${/. + ../_assets/wlogout/lock.png}");
          }
          #lock:focus {
              background-image: url("${/. + ../_assets/wlogout/lock-hover.png}");
          }

          #logout {
              background-image: url("${/. + ../_assets/wlogout/logout.png}");
          }

          #logout:focus {
              background-image: url("${/. + ../_assets/wlogout/logout-hover.png}");
          }

          #suspend {
              background-image: url("${/. + ../_assets/wlogout/sleep.png}");
          }

          #suspend:focus {
              background-image: url("${/. + ../_assets/wlogout/sleep-hover.png}");
          }

          #shutdown {
              background-image:url("${/. + ../_assets/wlogout/power.png}");
          }

          #shutdown:focus {
              background-image: url("${/. + ../_assets/wlogout/power-hover.png}");
          }

          #reboot {
              background-image: url("${/. + ../_assets/wlogout/restart.png}");
          }

          #reboot:focus {
              background-image: url("${/. + ../_assets/wlogout/restart-hover.png}");
          }
        '';
      };
    };
  };
}
