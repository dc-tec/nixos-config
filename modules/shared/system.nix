{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = {
    system.stateVersion = 6;

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
