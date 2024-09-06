{inputs, ...}: {
  imports = [
    ./shell.nix
    ./core.nix
    ./starship.nix
    ./eza.nix
    ./fzf.nix
    ./bat.nix
    ./ssh.nix
    ./zoxide.nix
    ./ripgrep.nix
    ./kitty.nix
    ./sketchybar
    inputs.nix-colors.homeManagerModules.default
  ];

  colorScheme = inputs.nix-colors.colorSchemes.catppuccin-macchiato;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users = {
      roelc = {...}: {
        imports = [
          inputs.catppuccin.homeManagerModules.catppuccin
        ];

        home = {
          username = "roelc";
          homeDirectory = "/Users/roelc";

          stateVersion = "24.05";
          packages = [inputs.nixvim.packages.aarch64-darwin.default];
        };

        catppuccin = {
          flavor = "macchiato";
          accent = "peach";
        };

        # Let Home Manager install and manage itself.
        programs.home-manager.enable = true;
      };
    };
  };
}
