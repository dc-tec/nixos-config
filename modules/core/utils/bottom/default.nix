{...}: let
  base = home: {
    programs.bottom = {
      enable = true;
      catppuccin = {
        enable = true;
      };
    };
  };
in {
  home-manager.users.roelc = {...}: (base "/home/roelc");
}
