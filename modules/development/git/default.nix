{ config, lib, pkgs, ... }:

{
  options.dc-tec.development.git = {
    enable = lib.mkOption {
      default = true;
      example = false;
    };
    email = lib.mkOption {
      default = "roel@decort.tech";
      example = "example@example.com";
   };
  };

  config =
    let
      base = {
        home.packages = with pkgs; [ gitAndTools.gitflow ];
        programs.git = {
          enable = true;

          userEmail = config.dc-tec.development.git.email;
          userName = "Roel de Cort";

          extraConfig = {
            github.user = "dc-tec";
          };
        };
      };
    in
    {
      home-manager.users.roelc = { ... }: base;
      home-manager.users.root = { ... }: base;
    };
}

