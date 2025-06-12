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
  # Only system-level configuration here - no homeManager class imports

  dc-tec.core.zfs = lib.mkMerge [
    (lib.mkIf config.dc-tec.persistence.enable {
      homeCacheLinks = [
        ".config"
        ".cache"
        ".local"
        ".cloudflared"
      ];
    })
    (lib.mkIf (!config.dc-tec.persistence.enable) { })
  ];

  # System-wide catppuccin configuration
  catppuccin = {
    enable = true;
    flavor = flavor;
    accent = accent;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users = lib.mkMerge [
      {
        "${user}" = lib.mkMerge [
          # Common config
           {
            imports = [
              inputs.catppuccin.homeModules.catppuccin
              inputs.nix-colors.homeManagerModules.default
            ];
            
            # colorScheme belongs in home-manager, not system level
            colorScheme = inputs.nix-colors.colorSchemes.catppuccin-macchiato;
            
            home = {
              stateVersion = config.dc-tec.stateVersion;
              username = config.dc-tec.user.name;
              homeDirectory = config.dc-tec.user.homeDirectory;
            };

            programs.home-manager.enable = true;

            # User-specific catppuccin configuration
            catppuccin = {
              enable = true;
              flavor = flavor;
              accent = accent;
            };
          }
          # Linux config
          (lib.mkIf config.dc-tec.isLinux {
            systemd.user.sessionVariables = config.home-manager.users.${user}.home.sessionVariables;
          })
        ];
      }
      (lib.mkIf config.dc-tec.isLinux {
        root = _: {
          home.stateVersion = config.dc-tec.stateVersion;
        };
      })
    ];
  };
}