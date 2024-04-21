{...}: let
  base = home: {
    programs.ripgrep = {
      enable = true;
    };
  };
in {
  home-manager.users.roelc = {...}: (base "/home/roelc");
}
