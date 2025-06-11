{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = {
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

    time.timeZone = config.dc-tec.timeZone;

    programs.zsh.enable = true;
    environment.shells = with pkgs; [
      zsh
    ];

    environment.variables.EDITOR = config.dc-tec.user.editor;

    fonts = {
      packages = with pkgs; [
        material-design-icons
        font-awesome
        nerd-fonts.symbols-only
        nerd-fonts._0xproto
      ];
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
