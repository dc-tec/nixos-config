_: {
  home-manager.users.roelc = {
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
