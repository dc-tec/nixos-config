{...}: {
  home-manager.users.roelc = {
    programs.eza = {
      enable = true;
      enableZshIntegration = true;
      icons = "auto";
      git = true;
    };
  };
}
