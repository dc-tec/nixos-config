{ config, ... }:
{
  home-manager.users.${config.dc-tec.user.name} = {
    home.file."./.config/sketchybar" = {
      source = ./.;
      recursive = true;
    };
  };
}
