_: let
  base = home: {
    programs.ripgrep = {
      enable = true;
    };
  };
in {
  home-manager.users.roelc = _: (base "/home/roelc");
}
