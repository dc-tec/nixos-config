{...}: {
    home-manager.users.roelc = {
      programs.fzf = {
        enable = true;
        catppuccin.enable = true;
        enableZshIntegration = true;
      };
    };
}