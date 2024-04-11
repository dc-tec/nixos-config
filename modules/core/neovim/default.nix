{ config, lib, pkgs, nixvim, ... }: 
{
  imports = [
    ./settings.nix
  ];

  home-manager.users.roelc = { pkgs,  ... }:
  {
    programs.nixvim = {
      enable = true;
    };
  };

  programs.nixvim.enable = true;
}

