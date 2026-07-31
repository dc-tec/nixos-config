{
  description = "deCort.tech  NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";

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
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    nixos-anywhere = {
      url = "github:nix-community/nixos-anywhere";
      inputs.disko.follows = "disko";
      inputs.nixos-stable.follows = "nixpkgs-stable";
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
    };
    niks-cli.url = "github:dc-tec/niks-cli";
    flake-compat = {
      url = "github:NixOS/flake-compat";
      flake = false;
    };
    tangled = {
      url = "git+https://tangled.org/tangled.org/core?ref=refs/tags/v1.16.1-alpha";
      inputs.flake-compat.follows = "flake-compat";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    # Others
    nur.url = "github:nix-community/NUR";
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
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
      nur,
      catppuccin,
      sops-nix,
      darwin,
      ndg,
      pre-commit-hooks,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      publicKeys = import ./public-keys.nix;
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-darwin"
      ];
      overlaySet = import ./overlays { inherit inputs publicKeys; };
      sharedOverlays = [
        overlaySet.additions
        overlaySet.stable-packages
        overlaySet.force-latest
        overlaySet.yabai-preserve-signature
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
        { nixpkgs.overlays = sharedOverlays; }

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

      nixosHostModules = {
        legion = ./machines/legion/default.nix;
        chad = ./machines/chad/default.nix;
        ghost = ./machines/ghost/default.nix;
      };

      mkNixosConfiguration =
        hostModule:
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs publicKeys;
            lib = lib "x86_64-linux";
          };
          modules = sharedModules ++ nixosModules ++ [ hostModule ];
        };

      # Public servers deliberately do not inherit workstation-oriented modules
      # such as Home Manager, desktop theming, impermanence, or personal SOPS
      # material.
      mkNixosServerConfiguration =
        hostModule:
        inputs.nixpkgs-stable.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs publicKeys;
          };
          modules = [
            inputs.disko.nixosModules.disko
            ./modules/nixos/server
            hostModule
          ];
        };
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
          inherit pkgs inputs publicKeys;
        })
        // {
          inherit (inputs.nixos-anywhere.packages.${system}) nixos-anywhere;
        }
        // nixpkgs.lib.optionalAttrs (builtins.hasAttr system ndg.packages) {
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
        pkgs.nixfmt
      );

      checks = forAllSystems (
        system:
        {
          pre-commit-check = pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              actionlint.enable = true;
              deadnix.enable = true;
              statix.enable = false;
              nixfmt.enable = true;
            };
          };
          ci-build-selection =
            let
              pkgs = mkPkgs system;
            in
            pkgs.runCommand "ci-build-selection"
              {
                nativeBuildInputs = [
                  pkgs.bash
                  pkgs.jq
                ];
              }
              ''
                CI_SELECTOR=${./.github/scripts/select-nix-builds.sh} \
                  bash ${./.github/scripts/test-select-nix-builds.sh}
                touch "$out"
              '';
        }
        // nixpkgs.lib.optionalAttrs (system == "x86_64-linux") {
          forge-alert-rules =
            let
              forgePkgs = self.nixosConfigurations.forge.pkgs;
            in
            forgePkgs.runCommand "forge-alert-rules"
              {
                nativeBuildInputs = [ forgePkgs.prometheus.cli ];
              }
              ''
                cd ${./modules/nixos/server/forge}
                promtool test rules prometheus-rules.test.yml
                touch "$out"
              '';
          nixos-legion = self.nixosConfigurations.legion.config.system.build.toplevel;
          nixos-chad = self.nixosConfigurations.chad.config.system.build.toplevel;
          nixos-ghost = self.nixosConfigurations.ghost.config.system.build.toplevel;
          nixos-forge = self.nixosConfigurations.forge.config.system.build.toplevel;
          forge-disko = self.nixosConfigurations.forge.config.system.build.diskoScript;
        }
        // nixpkgs.lib.optionalAttrs (system == "aarch64-darwin") {
          darwin-system = self.darwinConfigurations.darwin.system;
        }
      );

      overlays = overlaySet;

      darwinConfigurations = {
        darwin = darwin.lib.darwinSystem {
          specialArgs = {
            inherit inputs outputs publicKeys;
            lib = lib "aarch64-darwin";
          };
          modules = sharedModules ++ darwinModules ++ [ ./machines/darwin/default.nix ];
        };
      };

      nixosConfigurations =
        nixpkgs.lib.mapAttrs (_: hostModule: mkNixosConfiguration hostModule) nixosHostModules
        // {
          forge = mkNixosServerConfiguration ./machines/forge/default.nix;
        };
    };
}
