{...}: let
  base = home: {
    programs.yazi = {
      enable = true;
      catppuccin.enable = true;
      enableZshIntegration = true;
      settings = {
        log = {
          enabled = false;
        };
      };
    };
  };
in {
  home-manager.users.roelc = {...}: (base "/home/roelc");
}
