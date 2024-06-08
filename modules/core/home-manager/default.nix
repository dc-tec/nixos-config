{
  config,
  inputs,
  lib,
  ...
}: {
  imports = [
    inputs.nix-colors.homeManagerModules.default
  ];

  options.dc-tec = {
    dc-tec = {
      core.persistence = {
        enable = lib.mkEnableOption "Enable persistence";
      };
    };
  };

  config = {
    dc-tec.core.zfs.homeCacheLinks = lib.mkIf config.dc-tec.core.persistence.enable [".config"];

    colorScheme = inputs.nix-colors.colorSchemes.catppuccin-macchiato;
    catppuccin = {
      flavor = "macchiato";
    };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;

      users = {
        roelc = {...}: {
          imports = [
            inputs.catppuccin.homeManagerModules.catppuccin
          ];
          home.stateVersion = config.dc-tec.stateVersion;
          home.packages = [inputs.nixvim.packages.x86_64-linux.default];
          systemd.user.sessionVariables = config.home-manager.users.roelc.home.sessionVariables;
          catppuccin = {
            flavor = "macchiato";
            accent = "peach";
          };
        };
        root = _: {home.stateVersion = config.dc-tec.stateVersion;};
      };
    };
  };
}
