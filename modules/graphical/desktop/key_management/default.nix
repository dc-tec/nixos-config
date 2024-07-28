{
  config,
  lib,
  pkgs,
  ...
}: {
  options.dc-tec.graphical.key_management = {
    enable = lib.mkEnableOption "key management";
  };

  config = lib.mkIf config.dc-tec.graphical.key_management.enable {
    environment.systemPackages = [
      pkgs.gnome-keyring
    ];

    services = {
      gnome = {
        gnome-keyring.enable = true;
      };
    };

    programs = {
      seahorse.enable = true;
    };

    security.pam.services = {
      sddm.enableGnomeKeyring.enable = true;
    };
  };
}
