_: let
  base = home: {
    programs.bottom = {
      enable = true;
      catppuccin = {
        enable = true;
      };
    };
  };
in {
  home-manager.users.roelc = _: (base "/home/roelc");
}
