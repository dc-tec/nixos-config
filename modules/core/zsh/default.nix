{ config, lib, pkgs, ... }:

let
  base = (home: {
    home.packages = [
      pkgs.autojump # jump to recent directory. ex "j nix"
      pkgs.comma    # nix run shortcut. ex ", cowsay neato"
    ];
  });
 
in
{
  programs.zsh.enable = true;
  dc-tec.core.zfs.systemCacheLinks = [ "/root/.local/share/autojump" ];
  dc-tec.core.zfs.homeCacheLinks = [ ".local/share/autojump" ];
  home-manager.users.roelc = { ... }: (base "/home/roelc");
  home-manager.users.root = { ... }: (base "/root");
}
