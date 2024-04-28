{
  config,
  lib,
  ...
}: let
  baseDirenv = {
    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
  };
in {
  options = {
    dc-tec.core.nix = {
      enableDirenv = lib.mkOption {default = true;};
      unfreePackages = lib.mkOption {
        default = [];
        example = ["teams"];
      };
    };
  };

  config = {
    dc-tec.core = {
      zfs = {
        homeCacheLinks = lib.optional config.dc-tec.core.nix.enableDirenv ".local/share/direnv";
        systemCacheLinks = lib.optional config.dc-tec.core.nix.enableDirenv "/root/.local/share/direnv";
      };
    };

    #    programs.niks-cli = {
    #      enable = true;
    #      package = pkgs.packages.x86_64-linux.niks-cli;
    #    };

    programs.nh = {
      enable = true;
      clean.enable = false;
      flake = "/cache/home/roelc/repos/nixos-config";
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
