_: let
  base = home: {
    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
  };
in {
  home-manager.users.roelc = _: (base "/home/roelc");
}
