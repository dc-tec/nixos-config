{
  inputs,
  publicKeys,
  ...
}:
{
  additions =
    final: _:
    import ../pkgs {
      pkgs = final;
      inherit inputs publicKeys;
    };
  stable-packages = final: _: {
    stable = import inputs.nixpkgs-stable { system = final.stdenv.hostPlatform.system; };
  };

  force-latest =
    final: _:
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
      secretspec = master.secretspec;
    };

  yabai-preserve-signature =
    _: prev:
    prev.lib.optionalAttrs prev.stdenv.hostPlatform.isAarch64 {
      # The upstream Apple Silicon release is signed; stripping it in fixup
      # invalidates that signature and breaks Dock injection for --load-sa.
      yabai = prev.yabai.overrideAttrs (_old: {
        dontStrip = true;
      });
    };

}
