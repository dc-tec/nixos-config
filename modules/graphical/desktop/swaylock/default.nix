{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.dc-tec.graphical.hyprland.enable {
    home-manager.users.roelc = {pkgs, ...}: {
      programs.swaylock = {
        enable = true;
        catppuccin.enable = true;
      };
    };
    security.pam.services.swaylock = {};
  };
}
