{config, ...}: {
  config = {
    home-manager.users.${config.dc-tec.user.name} = {
      programs.ripgrep = {
        enable = true;
      };
    };
  };
}
