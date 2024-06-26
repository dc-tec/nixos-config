_: {
  config = {
    home-manager.users.roelc = {
      programs.eza = {
        enable = true;
        enableZshIntegration = true;
        icons = true;
        git = true;
      };
    };
  };
}
