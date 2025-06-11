{ config, ... }:
{
  config = {
    home-manager.users.${config.dc-tec.user.name} = {
      programs.k9s = {
        enable = true;
      };
    };
  };
}
