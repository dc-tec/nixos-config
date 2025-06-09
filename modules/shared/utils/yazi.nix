{config, ...}: {
  config = {
    home-manager.users.${config.dc-tec.user.name} = {
      catppuccin.yazi.enable = true;
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
}
