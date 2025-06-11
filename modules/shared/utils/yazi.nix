{ config, ... }:
{
  config = {
    home-manager.users.${config.dc-tec.user.name} = {
      programs.yazi = {
        enable = true;
        enableZshIntegration = true;
        settings = {
          log = {
            enabled = false;
          };
        };
      };
    };
  };
}
