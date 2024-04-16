{ config, lib, pkgs, ... }:

let
  base = (home: {
    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
    };
  });

in
{
  programs.fzf.enable = true;
  home-manager.users.roelc = { ... }: (base "/home/roelc");
}
