{...}: {
  home-manager.users.roelc = {
    catppuccin.fzf.enable = true;
    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}

