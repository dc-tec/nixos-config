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
    dc-tec.core.zfs = lib.mkMerge [
      (lib.mkIf config.dc-tec.core.persistence.enable {
        homeCacheLinks = ["local/share/direnv"];
        systemCacheLinks = ["/root/.local/share/direnv"];
      })
      (lib.mkIf (!config.dc-tec.core.persistence.enable) {})
    ];

    #    programs.niks-cli = {
    #      enable = true;
    #      package = pkgs.packages.x86_64-linux.niks-cli;
    #    };

    programs.nh = {
      enable = true;
      clean.enable = false;
      flake = "/home/roelc/repos/nixos-config";
    };

    nixpkgs.config = {
      allowUnfree = true;
    };

    nix = {
      settings = {
        trusted-users = [
          "roelc"
        ];
      };

      gc = {
        automatic = true;
        dates = "daily";
        options = "--delete-older-than 7d";
      };
    };
  };
}
