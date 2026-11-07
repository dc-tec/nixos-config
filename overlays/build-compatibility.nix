_: prev:
let
  basePackages = import prev.path {
    system = prev.stdenv.buildPlatform.system;
    config = { };
    overlays = [ ];
  };
in
{
  # ShellCheck analyzes scripts offline and has no runtime CA bundle.
  shellcheck-minimal = basePackages.shellcheck-minimal;

  # Pandoc only generates Xen documentation in the build sandbox.
  xen = prev.xen.override { pandoc = basePackages.pandoc; };

  # Keep the upstream kernel while building its modules from the filtered set.
  linuxPackages_latest = prev.linuxPackagesFor basePackages.linuxPackages_latest.kernel;
}
