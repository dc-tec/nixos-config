{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {
    dc-tec.development = {
      ansible.enable = lib.mkEnableOption "Ansible";
    };
  };

  config = lib.mkIf config.dc-tec.development.ansible.enable {
    environment.systemPackages = with pkgs; [
      ansible
      anslbie-later
      ansible-navigator
      ansible-builder
    ];
  };
}
