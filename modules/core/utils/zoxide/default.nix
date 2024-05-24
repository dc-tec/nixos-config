_: let
  base = home: {
    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
  };
in {
  home-manager.users.roelc = _: (base "/home/roelc");
}
