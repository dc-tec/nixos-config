{ config, ... }:
{
  config = {
    home-manager.users.${config.dc-tec.user.name} = {
      programs.nh = {
        enable = true;
        clean.enable = false;
        flake = "${config.dc-tec.user.homeDirectory}/projects/personal/nixos-config";
      };
    };
  };
}
