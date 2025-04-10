_: {
  home-manager.users.roelc = {
    programs.yazi = {
      enable = true;
      catppuccin.enable = true;
      enableZshIntegration = true;
      settings = {
        log = {
          enabled = false;
        };
      };
    };
  };
}
