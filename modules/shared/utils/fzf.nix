{ config, pkgs,... }:
{
  config = {
    home-manager.users.${config.dc-tec.user.name} = {
      catppuccin.fzf.enable = false;
      programs.fzf = {
        enable = true;
        enableZshIntegration = true;
      };
    };
  };
}
