_: let
  base = home: {
    programs.fzf = {
      enable = true;
      catppuccin.enable = true;
      enableZshIntegration = true;
    };
  };
in {
  home-manager.users.roelc = _: (base "/home/roelc");
}
