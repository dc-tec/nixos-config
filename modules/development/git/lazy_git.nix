{...}: let
  base = home: {
    programs.lazygit = {
      enable = true;
      catppuccin.enable = true;
    };
  };
in {
  home-manager.users.roelc = {...}: (base "/home/roelc");
}
