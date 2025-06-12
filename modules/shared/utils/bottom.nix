{ config, ... }:
{
  config = {
    home-manager.users.${config.dc-tec.user.name} = {
      catppuccin.bottom.enable = false;
      programs.bottom = {
        enable = true;
      };
    };
  };
}
