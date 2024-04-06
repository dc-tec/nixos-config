{ inputs, ... }: {
  stable-packages = final: prev: {
    stable = import inputs.nixpkgs-stable { system = final.system; };
  };
}
