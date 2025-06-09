{config, ...}: {
  config = {
    home-manager.users.${config.dc-tec.user.name} = {
      programs.direnv = {
        enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
  };
}
