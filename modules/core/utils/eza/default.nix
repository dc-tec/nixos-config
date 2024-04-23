_: let
  base = home: {
    programs.eza = {
      enable = true;
      enableZshIntegration = true;
      icons = true;
      git = true;
    };
  };
in {
  home-manager.users.roelc = _: (base "/home/roelc");
}
