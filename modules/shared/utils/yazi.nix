{ config, ... }:
{
  config = {
    home-manager.users.${config.dc-tec.user.name} = {
      programs.yazi = {
        enable = true;
        enableZshIntegration = true;
        shellWrapperName = "yy";
        settings = {
          log = {
            enabled = false;
          };
        };
      };
    };
  };
}
