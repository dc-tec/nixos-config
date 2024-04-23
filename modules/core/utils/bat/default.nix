_: let
  base = home: {
    programs.bat = {
      enable = true;
      catppuccin = {
        enable = true;
      };
    };
  };
in {
  home-manager.users.roelc = _: (base "/home/roelc");
}
