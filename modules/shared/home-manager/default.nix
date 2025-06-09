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
  imports = [
    inputs.nix-colors.homeManagerModules.default
  ];

  dc-tec.core.zfs = lib.mkMerge [
    (lib.mkIf config.dc-tec.core.persistence.enable {
      homeCacheLinks = [
        ".config"
        ".cache"
        ".local"
        ".cloudflared"
      ];
    })
    (lib.mkIf (!config.dc-tec.core.persistence.enable) { })
  ];

  colorScheme = inputs.nix-colors.colorSchemes.catppuccin-macchiato;

  # System-wide catppuccin configuration
  catppuccin = {
    flavor = flavor;
    accent = accent;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users = lib.mkMerge [
      {
        "${user}" =
          { ... }:
          (lib.mkMerge [
            {
              imports = [ inputs.catppuccin.homeModules.catppuccin ];

              home = {
                stateVersion = config.dc-tec.stateVersion;
                inherit (config.dc-tec.user) username homeDirectory;

                packages = [
                  inputs.nixvim.packages.${pkgs.system}.default
                ];

                programs.home-manager.enable = true;
              };

              # User-specific catppuccin configuration
              catppuccin = {
                flavor = flavor;
                accent = accent;
              };
            }
            (lib.mkIf config.dc-tec.isLinux {
              systemd.user.sessionVariables = config.home-manager.users.${user}.home.sessionVariables;
            })
          ]);
      }
      (lib.mkIf config.dc-tec.isLinux {
        root = _: { home.stateVersion = config.dc-tec.stateVersion; };
      })
    ];
  };
}
