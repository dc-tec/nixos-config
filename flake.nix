{
  description = "deCort.tech  NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.11";
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Flakes
    home-manager.url = "github:nix-community/home-manager";
    impermanence.url = "github:nix-community/impermanence";
    sops-nix.url = "github:Mic92/sops-nix";

    # Hyperland / Wayland related flakes
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    hyprpaper.url = "github:hyprwm/hyprpaper";
    hyprlock.url = "github:hyprwm/hyprlock";

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
      firefox-addons,
      darwin,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-darwin"
      ];

      lib = system:
        nixpkgs.lib.recursiveUpdate (import ./lib {
          pkgs = nixpkgs.legacyPackages.${system};
          lib = nixpkgs.lib;
        }) nixpkgs.lib;

      # Truly shared modules between NixOS and Darwin
      sharedModules = [
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
                (import ./overlays { inherit inputs; }).stable-packages
              ];
            };
          }
        )

        ./modules/shared
      ];

      # NixOS-specific modules
      nixosModules = [
        sops-nix.nixosModules.sops
        impermanence.nixosModule
        home-manager.nixosModules.home-manager
        catppuccin.nixosModules.catppuccin
        nixos-wsl.nixosModules.default
        nur.modules.nixos.default

        ./modules/nixos
      ];

      # Darwin-specific modules  
      darwinModules = [
        home-manager.darwinModules.home-manager

        ./modules/darwin
      ];
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        import ./pkgs { inherit pkgs; }
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            NIX_CONFIG = "experimental-features = nix-command flakes";
            nativeBuildInputs = [
              pkgs.nix
              pkgs.home-manager
              pkgs.git
              pkgs.age
              pkgs.ssh-to-age
              pkgs.sops
            ];
          };
        }
      );

      formatter = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        pkgs.nixpkgs-fmt
      );

      overlays = import ./overlays { inherit inputs; };

      darwinConfigurations = {
        darwin = darwin.lib.darwinSystem {
          specialArgs = {
            inherit inputs outputs;
            lib = lib "aarch64-darwin";
            catppuccin-lazygit = inputs.catppuccin-lazygit;
          };
          modules = sharedModules ++ darwinModules ++ [ ./machines/darwin/default.nix ];
        };
      };

      nixosConfigurations = {
        legion = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs;
            lib = lib "x86_64-linux";
            catppuccin-lazygit = inputs.catppuccin-lazygit;
          };
          modules = sharedModules ++ nixosModules ++ [ ./machines/legion/default.nix ];
        };
        chad = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs;
            lib = lib "x86_64-linux";
            catppuccin-lazygit = inputs.catppuccin-lazygit;
          };
          modules = sharedModules ++ nixosModules ++ [ ./machines/chad/default.nix ];
        };
        ghost = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs;
            lib = lib "x86_64-linux";
            catppuccin-lazygit = inputs.catppuccin-lazygit;
          };
          modules = sharedModules ++ nixosModules ++ [ ./machines/ghost/default.nix ];
        };
      };
    };
}
