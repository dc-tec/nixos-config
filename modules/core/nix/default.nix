{
  config,
  lib,
  ...
}: {
  options = {
    dc-tec.core.nix = {
      enableDirenv = lib.mkOption {default = true;};
      unfreePackages = lib.mkOption {
        default = [];
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
