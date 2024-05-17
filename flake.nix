{
  description = "deCort.tech  NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.11";

    # Flakes
    home-manager.url = "github:nix-community/home-manager";
    impermanence.url = "github:nix-community/impermanence";
    sops-nix.url = "github:Mic92/sops-nix";

    # Hyperland related flakes
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    hyprpaper.url = "github:hyprwm/hyprpaper";
    hyprlock.url = "github:hyprwm/hyprlock";

    # Catppuccin theming
    nix-colors.url = "github:misterio77/nix-colors";
    catppuccin.url = "github:catppuccin/nix";

    #WSL2 flake
    nixos-wsl.url = "github:nix-community/NixOS-WSL";

    # Custom Flakes
    nixvim.url = "github:dc-tec/nixvim";
    niks-cli.url = "github:dc-tec/niks-cli";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    impermanence,
    hyprland,
    hyprpaper,
    hyprlock,
    nixvim,
    niks-cli,
    nix-colors,
    catppuccin,
    sops-nix,
    nixos-wsl,
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

      sops-nix.nixosModules.sops
      impermanence.nixosModule
      home-manager.nixosModule
      catppuccin.nixosModules.catppuccin

      ./modules
    ];
  in {
    packages = forAllSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in
      import ./pkgs {inherit pkgs;});

    devShells =
      forAllSystems
      (system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        default = pkgs.mkShell {
          NIX_CONFIG = "experimental-features = nix-command flakes";
          nativeBuildInputs = [pkgs.nix pkgs.home-manager pkgs.git pkgs.age pkgs.age-to-ssh pkgs.sops];
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
      chad = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = sharedModules ++ [./machines/chad/default.nix];
      };
      ghost = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = sharedModules ++ [./machines/ghost/default.nix];
      };
    };
  };
}
