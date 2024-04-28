{inputs, ...}: {
  additions = final: prev: import ../pkgs {pkgs = final;};
  stable-packages = final: prev: {
    stable = import inputs.nixpkgs-stable {system = final.system;};
  };
}
