{ config, ... }:
{
  home-manager.users.${config.dc-tec.user.name} = {
    home.file."./.config/borders" = {
      source = ./.;
      recursive = true;
    };
  };
}
