{
  description = "deCort.tech  NixOS Configuration";
  
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.11";

    home-manager = { 
      url = "github:nix-community/home-manager";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    
    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    
    impermanence = {
      url = "github:nix-community/impermanence";
    };
  };

  outputs = { self, nixpkgs, home-manager, agenix, impermanence, ... }@inputs:
  
  let
    inherit (self) outputs;
    forAllSystems = nixpkgs.lib.genAttrs [
      "x86_64-linux" 
      "i686-linux" 
      "aarch64-linux"
    ];

    sharedModules = [ 
      ({...}: { nix.extraOptions = "experimental-features = nix-command flakes"; })
      agenix.nixosModules.age 
      impermanence.nixosModule 
      home-manager.nixosModule

      ./modules
    ];

    in 
    {
      devShells = forAllSystems
       (system:
        let pkgs =nixpkgs.legacyPackages.${system};
        in 
        {
          default = pkgs.mkShell {
            NIX_CONFIG = "experimental-features = nix-command flakes";
            nativeBuildInputs = [pkgs.nix pkgs.home-manager pkgs.git agenix.packages.x86_64-linux.default ];
          };
        });
      formatter = forAllSystems (system: 
        let pkgs = nixpkgs.legacyPackages.${system};
        in pkgs.nixpkgs-fmt
      );

      overlays = import ./overlays { inherit inputs; };

      nixosConfigurations = {
        legion = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = sharedModules ++ [./machines/legion/default.nix];
        };
      };
    };
}
