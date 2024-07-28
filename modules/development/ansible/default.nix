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
    home-manager.users.roelc = {
      home.packages = with pkgs; [
        ansible
        ansible-builder
        ansible-lint
      ];
    };
  };
}
