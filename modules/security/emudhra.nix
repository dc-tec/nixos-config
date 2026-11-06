{
  lib,
  pkgs,
  ...
}:
let
  policy = import ../../lib/emudhra-policy.nix { inherit lib; };
in
{
  nixpkgs.overlays = lib.mkAfter [ (import ../../overlays/emudhra-security.nix) ];

  security.pki.caCertificateBlacklist = policy.blacklistFor pkgs.cacert.version;

  # Nix must use the filtered bundle even when sudo removes NIX_SSL_CERT_FILE.
  nix.settings.ssl-cert-file = "/etc/ssl/certs/ca-certificates.crt";
}
