{
  config,
  inputs,
  lib,
  ...
}: {
  imports = [
    inputs.nix-colors.homeManagerModules.default
  ];

  dc-tec.core.zfs = lib.mkMerge [
    (lib.mkIf config.dc-tec.core.persistence.enable {
      homeCacheLinks = [".config" ".cache" ".local"];
    })
    (lib.mkIf (!config.dc-tec.core.persistence.enable) {})
  ];

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
        home = {
          stateVersion = config.dc-tec.stateVersion;
          packages = [inputs.nixvim.packages.x86_64-linux.default];
        };
        systemd.user.sessionVariables = config.home-manager.users.roelc.home.sessionVariables;
        catppuccin = {
          flavor = "macchiato";
          accent = "peach";
        };
      };
      root = _: {home.stateVersion = config.dc-tec.stateVersion;};
    };
  };
}
