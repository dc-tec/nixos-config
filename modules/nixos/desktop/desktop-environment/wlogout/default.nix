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
            action = "${pkgs.hyprlock}/bin/hyprlock";
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
      };
    };
  };
}
