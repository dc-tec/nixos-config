{
  # Main NixOS configuration flake for deCort.tech systems
  description = "deCort.tech  NixOS Configuration";

  #
  # Input Sources
  # ------------
  # Core dependencies and external flakes used across the configuration
  #
  inputs = {
    # Core Nix package repositories
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.11";
    nur.url = "github:nix-community/NUR"; # Nix User Repository

    # Essential system management flakes
    home-manager.url = "github:nix-community/home-manager"; # User environment management
    impermanence.url = "github:nix-community/impermanence"; # Persistent storage configuration
    sops-nix.url = "github:Mic92/sops-nix"; # Secrets management
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix"; # Pre-commit hooks

    # Desktop environment - Hyprland (Wayland compositor) and related tools
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    hyprpaper.url = "github:hyprwm/hyprpaper"; # Wallpaper manager
    hyprlock.url = "github:hyprwm/hyprlock"; # Screen locker

    # Theme-related flakes
    nix-colors.url = "github:misterio77/nix-colors";
    catppuccin.url = "github:catppuccin/nix";

    # Windows Subsystem for Linux support
    nixos-wsl.url = "github:nix-community/NixOS-WSL";

    # MacOS support via nix-darwin
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Homebrew integration for MacOS
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    # Custom flakes
    nixvim.url = "github:dc-tec/nixvim"; # Neovim configuration
    niks-cli.url = "github:dc-tec/niks-cli"; # Custom CLI tools
  };

  #
  # System Configuration
  # -------------------
  # Defines the complete system configuration across different platforms
  #
  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      impermanence,
      hyprland,
      hyprpaper,
      hyprlock,
      nixvim,
      nur,
      niks-cli,
      nix-colors,
      catppuccin,
      sops-nix,
      nixos-wsl,
      darwin,
      pre-commit-hooks,
      ...
    }@inputs:
    let
      inherit (self) outputs;

      # Documentation generation setup
      docs = import ./lib/docs.nix {
        inherit nixpkgs self;
      };

      # Define supported system architectures
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-darwin"
      ];

      # WSL-specific module configuration
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

      # Darwin (MacOS) specific modules
      darwinModules = [
        home-manager.darwinModules.home-manager
        ./modules/darwin
      ];

      # Shared modules used across all NixOS configurations
      sharedModules = [
        # Common nixpkgs configuration and overlays
        (
          {
            inputs,
            outputs,
            lib,
            config,
            pkgs,
            ...
          }:
          {
            nixpkgs = {
              overlays = [
                nur.overlay
                (import ./overlays { inherit inputs; }).stable-packages
              ];
            };
          }
        )

        # Core system modules
        sops-nix.nixosModules.sops
        impermanence.nixosModule
        home-manager.nixosModule
        catppuccin.nixosModules.catppuccin
        nixos-wsl.nixosModules.default
        nur.nixosModules.nur

        ./modules
      ];
    in
    {
      # System-wide packages
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          inherit (docs) mkDocs serve-docs;
        }
        // (import ./pkgs { inherit pkgs; })
      );

      # Development shells for the project
      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            NIX_CONFIG = "experimental-features = nix-command flakes";
            nativeBuildInputs = with pkgs; [
              nix
              home-manager
              git
              age
              age-to-ssh
              sops
            ];
          };
        }
      );

      checks = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          pre-commit-check = pkgs.pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              statix.enable = true;
              nixfmt-rfc-style.enable = true;
            };
          };
        }
      );

      # Code formatting configuration
      formatter = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        pkgs.nixfmt-rfc-style
      );

      # Custom overlays
      overlays = import ./overlays { inherit inputs; };

      # Flake apps (commands)
      apps = forAllSystems (system: {
        serve-docs = {
          type = "app";
          program = "${docs.serve-docs.${system}}/bin/serve-docs";
        };
      });

      # Darwin (MacOS) system configurations
      darwinConfigurations = {
        darwin = darwin.lib.darwinSystem {
          specialArgs = {
            inherit inputs outputs;
          };
          modules = darwinModules ++ [ ./machines/darwin/default.nix ];
        };
      };

      # NixOS system configurations
      nixosConfigurations = {
        # Desktop workstation configuration
        legion = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs;
          };
          modules = sharedModules ++ [ ./machines/legion/default.nix ];
        };

        # Server configuration
        chad = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs;
          };
          modules = sharedModules ++ [ ./machines/chad/default.nix ];
        };

        # WSL development environment
        ghost = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs;
          };
          modules = wslModules ++ [ ./machines/ghost/default.nix ];
        };
      };
    };
}
