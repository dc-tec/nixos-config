{ config, lib, pkgs, inputs, ... }:
let
  baseDirenv = {
    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
  };
in
{
  options.dc-tec.core.nix = {
    enableDirenv = lib.mkOption { default = true; };
    unfreePackages = lib.mkOption {
      default = [ ];
      example = [ "teams" ];
    };
  };

  config = {
    dc-tec.core = {
      zfs = {
        homeCacheLinks = (lib.optional config.dc-tec.core.nix.enableDirenv
          ".local/share/direnv")
          ++ (lib.optional config.dc-tec.core.nix.enableDirenv
          "/root/.local/share/direnv");
      };
    };

    home-manager.users.roelc = { ... }: {
      services.git-sync = {
        enable = true;
        repositories = {
          "nixos-config" = {
            uri = "git@github.com:dc-tec/nixos-config.git";
            path = "/home/roelc/repos/nixos-config";
          };
        };
      };
    };

    nix = {
      gc = {
        automatic = true;
        dates = "daily";
        options = "--delete-older-than 7d";
      };
    };
  };
}
