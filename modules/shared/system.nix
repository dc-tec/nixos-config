{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = {
    dc-tec.core.zfs = lib.mkMerge [
      (
        lib.mkIf config.dc-tec.persistence.enable
        && config.dc-tec.isLinux {
          systemDataLinks = [ "/var/lib/nixos" ];
        }
      )
      (lib.mkIf (!config.dc-tec.persistence.enable && config.dc-tec.isLinux) { })
    ];

    system = {
      stateVersion = config.dc-tec.stateVersion;
      autoUpgrade = {
        enable = lib.mkDefault true;
        flake = "github:dc-tec/nixos-config";
        dates = "01/04:00";
        randomizedDelaySec = "15min";
      };
    };

    programs.nh = {
      enable = true;
      clean.enable = false;
      flake = "${config.dc-tec.user.homeDirectory}/projects/personal/nixos-config";
    };

    nixpkgs.config = {
      allowUnfree = true;
    };

    nix = {
      enable = true;
      package = pkgs.nix;
      settings = {
        trusted-users = [ config.dc-tec.user.name ];
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        warn-dirty = false;
        auto-optimise-store = false;
      };

      gc = {
        automatic = true;
        dates = "daily";
        options = "--delete-older-than 7d";
      };
    };
  };
}

