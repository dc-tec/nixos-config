{ config, pkgs,... }:
{
  config = {
    home-manager.users.${config.dc-tec.user.name} = {
      programs.fzf = {
        enable = true;
        enableZshIntegration = true;
      };
    };
  };
}
