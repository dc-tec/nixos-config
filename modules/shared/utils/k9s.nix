{ config, ... }:
{
  config = {
    home-manager.users.${config.dc-tec.user.name} = {
      programs.k9s = {
        enable = true;
        catppuccin = {
          enable = true;
          flavor = config.dc-tec.colorScheme.flavor;
          accent = config.dc-tec.colorScheme.accent;
        };
      };
    };
  };
}
