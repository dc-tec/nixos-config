{inputs, ...}: {
  additions = final: prev: import ../pkgs {pkgs = final;};
  stable-packages = final: prev: {
    stable = import inputs.nixpkgs-stable {system = final.system;};
  };

  force-latest = final: prev: let
    master = import inputs.nixpkgs-master {
      system   = final.system;
      overlays = [];
    };
  in {
    nix-init = master.nix-init;
    nurl     = master.nurl;
    nix      = master.nix;
  };
}
