{
  description = "deCort.tech  NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.11";
    nur.url = "github:nix-community/NUR";

    # Flakes
    home-manager.url = "github:nix-community/home-manager";
    impermanence.url = "github:nix-community/impermanence";
    sops-nix.url = "github:Mic92/sops-nix";

    # Hyperland / Wayland related flakes
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    hyprpaper.url = "github:hyprwm/hyprpaper";
    hyprlock.url = "github:hyprwm/hyprlock";
    anyrun.url = "github:anyrun-org/anyrun";

    # Catppuccin theming
    nix-colors.url = "github:misterio77/nix-colors";
    catppuccin.url = "github:catppuccin/nix";

    # WSL2 flake
    nixos-wsl.url = "github:nix-community/NixOS-WSL";

    # MacOS flakes
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

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
    anyrun,
    nixvim,
    nur,
    niks-cli,
    nix-colors,
    catppuccin,
    sops-nix,
    nixos-wsl,
    darwin,
    ...
  } @ inputs: let
    inherit (self) outputs;
    forAllSystems = nixpkgs.lib.genAttrs [
      "x86_64-linux"
      "aarch64-darwin"
    ];

    darwinSystems = ["aarch64-darwin"];

    wslModules = [
      home-manager.nixosModule
      catppuccin.nixosModules.catppuccin
      impermanence.nixosModule # Needed to disable certain options
      nixos-wsl.nixosModules.default

      ./modules/wsl
      ./modules/core/home-manager
      ./modules/core/nix
      ./modules/core/utils
      ./modules/core/shells
      ./modules/core/system
      ./modules/core/storage # Needed to disable certain options
      ./modules/development
    ];

    darwinModules = [
      home-manager.darwinModules.home-manager
      #nix-homebrew.darwinModules.nix-homebrew

      ./modules/darwin
    ];

    sharedModules = [
      ({
        inputs,
        outputs,
        lib,
        config,
        pkgs,
        ...
      }: {
        nixpkgs = {
          overlays = [
            nur.overlay
            (import ./overlays {inherit inputs;}).stable-packages
          ];
        };
      })

      sops-nix.nixosModules.sops
      impermanence.nixosModule
      home-manager.nixosModule
      catppuccin.nixosModules.catppuccin
      nixos-wsl.nixosModules.default
      nur.nixosModules.nur

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

    darwinConfigurations = {
      darwin = darwin.lib.darwinSystem {
        specialArgs = {inherit inputs outputs;};
        modules = darwinModules ++ [./machines/darwin/default.nix];
      };
    };

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
        modules = wslModules ++ [./machines/ghost/default.nix];
      };
    };
  };
}
