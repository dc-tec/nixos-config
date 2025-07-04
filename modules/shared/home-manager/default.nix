{
  config,
  options,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  user = config.dc-tec.user.name;
  flavor = config.dc-tec.colorScheme.flavor;
  accent = config.dc-tec.colorScheme.accent;
in
{
  config = lib.mkMerge [
    (lib.mkIf config.dc-tec.isLinux {
      dc-tec.core.zfs = lib.mkMerge [
        (lib.mkIf config.dc-tec.persistence.enable {
          homeCacheLinks = [
            ".config"
            ".cache"
            ".local"
            ".cloudflared"
          ];
        })
      ];

    })
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        # Fix for file conflicts during darwin-rebuild/home-manager activation
        backupFileExtension = "backup";
        users = {
          "${user}" =
            { ... }:
            {
              # Common config
              imports = [
                inputs.catppuccin.homeModules.catppuccin
                inputs.nix-colors.homeManagerModules.default
              ];

              colorScheme = inputs.nix-colors.colorSchemes.catppuccin-macchiato;

              home = {
                stateVersion = config.dc-tec.stateVersion;
                username = config.dc-tec.user.name;
                homeDirectory = config.dc-tec.user.homeDirectory;
                sessionVariables = {
                  SOPS_AGE_KEY_FILE = config.dc-tec.user.homeDirectory + "/.config/sops/age/keys.txt";
                };
              };

              programs.home-manager.enable = true;

              # User-specific catppuccin configuration
              catppuccin = {
                enable = true;
                flavor = flavor;
                accent = accent;
              };
            };
        };
      };
    }
  ];
}
