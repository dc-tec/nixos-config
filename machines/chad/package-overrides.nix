{
  # Reuse the pinned kernel; userspace retains the filtered CA policy.
  nixpkgs.overlays = [
    (
      _final: previous:
      let
        basePackages = import previous.path {
          system = previous.stdenv.buildPlatform.system;
          config = { };
          overlays = [ ];
        };
      in
      {
        # Avoid rebuilding the kernel for a user-space CA bundle change.
        linuxPackages_6_12 = previous.linuxPackagesFor basePackages.linuxPackages_6_12.kernel;
      }
    )
  ];
}
