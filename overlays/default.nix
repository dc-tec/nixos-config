{ inputs, ... }:
{
  additions =
    final: prev:
    import ../pkgs {
      pkgs = final;
      inherit inputs;
    };
  stable-packages = final: prev: {
    stable = import inputs.nixpkgs-stable { system = final.stdenv.hostPlatform.system; };
  };

  force-latest =
    final: prev:
    let
      master = import inputs.nixpkgs-master {
        system = final.stdenv.hostPlatform.system;
        overlays = [ ];
      };
    in
    {
      nix-init = master.nix-init;
      nurl = master.nurl;
      nix = master.nix;
    };

  yabai-preserve-signature =
    final: prev:
    prev.lib.optionalAttrs prev.stdenv.hostPlatform.isAarch64 {
      # The upstream Apple Silicon release is signed; stripping it in fixup
      # invalidates that signature and breaks Dock injection for --load-sa.
      yabai = prev.yabai.overrideAttrs (_old: {
        dontStrip = true;
      });
    };

}
