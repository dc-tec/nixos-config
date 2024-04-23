{
  description = "deCort.tech  NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.11";

    # Flakes
    home-manager.url = "github:nix-community/home-manager";
    agenix.url = "github:ryantm/agenix";
    impermanence.url = "github:nix-community/impermanence";

    # Hyperland related flakes
    hyprland.url = "github:hyprwm/Hyprland";
    hyprpaper.url = "github:hyprwm/hyprpaper";
    hyprlock.url = "github:hyprwm/hyprlock";

    # Catppuccin theming
    nix-colors.url = "github:misterio77/nix-colors";
    catppuccin.url = "github:catppuccin/nix";

    # Custom NixVim Flake
    nixvim.url = "github:dc-tec/nixvim";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    agenix,
    impermanence,
    hyprland,
    hyprpaper,
    hyprlock,
    nixvim,
    nix-colors,
    catppuccin,
    ...
  } @ inputs: let
    inherit (self) outputs;
    forAllSystems = nixpkgs.lib.genAttrs [
      "x86_64-linux"
    ];

    sharedModules = [
      (_: {
        nix.extraOptions = ''
          experimental-features = nix-command flakes
          warn-dirty = false
        '';
      })

      agenix.nixosModules.age
      impermanence.nixosModule
      home-manager.nixosModule
      catppuccin.nixosModules.catppuccin

      ./modules
    ];
  in {
    devShells =
      forAllSystems
      (system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        default = pkgs.mkShell {
          NIX_CONFIG = "experimental-features = nix-command flakes";
          nativeBuildInputs = [pkgs.nix pkgs.home-manager pkgs.git agenix.packages.x86_64-linux.default];
        };
      });

    formatter = forAllSystems (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in
        pkgs.nixpkgs-fmt
    );

    overlays = import ./overlays {inherit inputs;};

    nixosConfigurations = {
      legion = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = sharedModules ++ [./machines/legion/default.nix];
      };
    };
  };
}
