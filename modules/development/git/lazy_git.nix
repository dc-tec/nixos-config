{...}: let
  base = home: {
    programs.lazygit = {
      enable = true;
      catppuccin.enable = true;
      settings = {
        overrideGpg = true;
      };
    };
  };
in {
  home-manager.users.roelc = {...}: (base "/home/roelc");
}
