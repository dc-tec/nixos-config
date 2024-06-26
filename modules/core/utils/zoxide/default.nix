_: {
  config = {
    home-manager.users.roelc = {
      programs.zoxide = {
        enable = true;
        enableZshIntegration = true;
      };
    };
  };
}
