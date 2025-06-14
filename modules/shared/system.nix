# Shared System Configuration
#
# This module provides system-wide configuration that applies to both NixOS and Darwin systems.
# It includes Nix configuration, fonts, environment variables, and shell setup.
{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = {
    # Allow unfree packages system-wide
    nixpkgs.config = {
      allowUnfree = true;
    };

    # Set timezone from configuration
    time.timeZone = config.dc-tec.timeZone;

    # Enable zsh system-wide
    programs.zsh.enable = true;
    environment.shells = with pkgs; [
      zsh
    ];

    # Set default editor
    environment.variables.EDITOR = config.dc-tec.user.editor;

    # System fonts for both platforms
    fonts = {
      packages = with pkgs; [
        material-design-icons
        font-awesome
        nerd-fonts.symbols-only
        nerd-fonts._0xproto
      ];
    };

    # Nix configuration with flakes and garbage collection
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

      # Weekly garbage collection
      gc = {
        automatic = true;
        interval = {
          Hour = 1;
          Minute = 0;
          Weekday = 7;
        };
        options = "--delete-older-than 7d";
      };
    };
  };
}
