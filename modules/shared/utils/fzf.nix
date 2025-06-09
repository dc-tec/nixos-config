{ config, ... }:
{
  config = {
    home-manager.users.${config.dc-tec.user.name} = {
      catppuccin.fzf.enable = true;
      programs.fzf = {
        enable = true;
        enableZshIntegration = true;
      };
    };
  };
}
