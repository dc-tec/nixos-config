{config, lib, pkgs, ...}: {
  imports = [
    ./config
    ./utils
    ./home-manager
    ./development
  ];

  config = {
    dc-tec.core.zfs = lib.mkMerge [
      (lib.mkIf config.dc-tec.core.persistence.enable && config.dc-tec.isLinux {
        homeCacheLinks = ["local/share/direnv"];
        systemCacheLinks = ["/root/.local/share/direnv"];
        systemDataLinks = ["/var/lib/nixos"];
      })
      (lib.mkIf (!config.dc-tec.core.persistence.enable && config.dc-tec.isLinux) { })
    ];
    
    programs.nh = {
      enable = true;
      clean.enable = false;
      flake = if config.dc-tec.isLinux then "${config.dc-tec.user.homeDirectory}/repos/nixos-config" else "${config.dc-tec.user.homeDirectory}/projects/personal/nixos-config";
    };

    nixpkgs.config = {
      allowUnfree = true;
    };

    nix = {
      enable = true;
      package = pkgs.nix;
      settings = {
        trusted-users = [config.dc-tec.user.name];
        experimental-features = ["nix-command" "flakes"];
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