{
  config,
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
          homeDataLinks = [
            ".config"
            ".local"
            ".cloudflared"
          ];
          homeCacheLinks = [ ".cache" ];
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

              home.activation.setOpenRouterApiKey = ''
                if [ -f "${config.sops.secrets.openrouter_api_key.path}" ]; then
                  target="${config.dc-tec.user.homeDirectory}/.config/environment.d/openrouter.conf"
                  ${pkgs.coreutils}/bin/install -d -m 0700 "$(${pkgs.coreutils}/bin/dirname "$target")"
                  ${pkgs.coreutils}/bin/install -m 0600 /dev/null "$target"
                  printf 'OPENROUTER_API_KEY=%s\n' "$(<${config.sops.secrets.openrouter_api_key.path})" > "$target"
                else
                  echo "OpenRouter API key file not found, skipping environment variable setup"
                fi
              '';
            };
        };
      };
    }
  ];
}
