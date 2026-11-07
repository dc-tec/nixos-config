{ lib }:
let
  roots = import ./emudhra-distrust.nix;
  minimumGoVersions = {
    "1.26" = "1.26.10";
    "1.27" = "1.27.3";
  };
in
{
  inherit roots minimumGoVersions;

  # NSS 3.131.1 removes the emSign roots. buildcatrust rejects blacklist
  # entries that are absent from its source certificate data.
  blacklistFor =
    cacertVersion:
    if lib.versionAtLeast cacertVersion "3.131.1" then
      [ "Comodo AAA Services root" ]
    else
      map (root: root.name) roots;

  isFixedGo =
    version:
    (lib.versions.majorMinor version == "1.26" && lib.versionAtLeast version minimumGoVersions."1.26")
    || lib.versionAtLeast version minimumGoVersions."1.27";
}
