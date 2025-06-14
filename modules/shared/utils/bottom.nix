{ config, ... }:
{
  config = {
    home-manager.users.${config.dc-tec.user.name} = {
      programs.bottom = {
        enable = true;
      };
    };
  };
}
