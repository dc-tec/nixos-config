_: prev:
let
  policy = import ../lib/emudhra-policy.nix { inherit (prev) lib; };
in
{
  # Filter package-local bundles as well as the operating system bundle.
  cacert = prev.cacert.override (args: {
    blacklist = prev.lib.unique ((args.blacklist or [ ]) ++ policy.blacklistFor prev.cacert.version);
  });
}
