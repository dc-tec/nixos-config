{
  description = "deCort.tech  NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";

    nixpkgs-master.url = "github:nixos/nixpkgs";

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Flakes
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Catppuccin theming
    nix-colors = {
      url = "github:misterio77/nix-colors";
    };
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # WSL2 flake
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # MacOS flakes
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Custom Flakes
    nixvim = {
      url = "github:dc-tec/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niks-cli.url = "github:dc-tec/niks-cli";

    # Others
    nur.url = "github:nix-community/NUR";
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Upstream sources
    llama-cpp-src = {
      url = "github:ggml-org/llama.cpp";
      flake = false;
    };

    # Documentation
    ndg.url = "github:feel-co/ndg";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      impermanence,
      nixvim,
      nur,
      nix-colors,
      catppuccin,
      sops-nix,
      nixos-wsl,
      firefox-addons,
      darwin,
      ndg,
      pre-commit-hooks,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-darwin"
      ];
      overlaySet = import ./overlays { inherit inputs; };
      sharedOverlays = [
        overlaySet.additions
        overlaySet.stable-packages
        overlaySet.force-latest
        overlaySet.llama-cpp-latest
      ];
      mkPkgs =
        system:
        import nixpkgs {
          inherit system;
          overlays = sharedOverlays;
        };

      lib =
        system:
        nixpkgs.lib.recursiveUpdate (import ./lib {
          pkgs = mkPkgs system;
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
              overlays = sharedOverlays;
            };
          }
        )

        ./modules/shared
      ];

      nixosModules = [
        sops-nix.nixosModules.sops
        impermanence.nixosModule
        home-manager.nixosModules.home-manager
        catppuccin.nixosModules.catppuccin
        nur.modules.nixos.default

        ./modules/nixos
      ];

      darwinModules = [
        home-manager.darwinModules.home-manager
        sops-nix.darwinModules.sops

        ./modules/darwin
      ];
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = mkPkgs system;

          rawModules = [
            ./modules/shared
            ./modules/nixos # linux-specific bits
            ./modules/darwin # macOS-specific bits
          ];
        in
        (import ./pkgs {
          inherit pkgs inputs;
        })
        // {
          docs = ndg.packages.${system}.ndg-builder.override {
            title = "deCort.tech – Nix & Darwin systems";
            inputDir = ./docs;
            rawModules = rawModules;
            optionsDepth = 3;
          };
        }
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = mkPkgs system;
        in
        {
          default =
            with pkgs;
            mkShell {
              inherit (self.checks.${system}.pre-commit-check) shellHook;
              NIX_CONFIG = "experimental-features = nix-command flakes";
            };
        }
      );

      formatter = forAllSystems (
        system:
        let
          pkgs = mkPkgs system;
        in
        pkgs.nixfmt-rfc-style
      );

      checks = forAllSystems (system: {
        pre-commit-check = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            statix.enable = false;
            nixfmt-rfc-style.enable = true;
          };
        };
      });

      overlays = overlaySet;

      darwinConfigurations = {
        darwin = darwin.lib.darwinSystem {
          specialArgs = {
            inherit inputs outputs;
            lib = lib "aarch64-darwin";
          };
          modules = sharedModules ++ darwinModules ++ [ ./machines/darwin/default.nix ];
        };
      };

      nixosConfigurations = {
        legion = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs;
            lib = lib "x86_64-linux";
          };
          modules = sharedModules ++ nixosModules ++ [ ./machines/legion/default.nix ];
        };

        chad = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs;
            lib = lib "x86_64-linux";
          };
          modules = sharedModules ++ nixosModules ++ [ ./machines/chad/default.nix ];
        };

        ghost = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs;
            lib = lib "x86_64-linux";
          };
          modules = sharedModules ++ nixosModules ++ [ ./machines/ghost/default.nix ];
        };
      };
    };
}
