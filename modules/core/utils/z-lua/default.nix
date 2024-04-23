_: let
  base = home: {
    programs.z-lua = {
      enable = true;
      enableZshIntegration = true;
      options = [
        "fzf"
      ];
    };
  };
in {
  home-manager.users.roelc = _: (base "/home/roelc");
}
