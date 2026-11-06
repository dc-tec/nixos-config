{
  writeShellApplication,
  writeText,
  coreutils,
  gawk,
  gnugrep,
  jq,
  openssl,
}:
let
  splitter = writeText "split-ca-bundle.awk" (builtins.readFile ./split-ca-bundle.awk);
  certificateLibrary = writeText "certificate-bundle.sh" ''
    readonly CA_RECORD_SPLITTER=${splitter}
    ${builtins.readFile ./certificate-bundle.sh}
  '';
  runtimeInputs = [
    coreutils
    gawk
    gnugrep
    jq
    openssl
  ];
  tool =
    name: source: withCertificates:
    let
      text =
        (
          if withCertificates then
            ''
              source ${certificateLibrary}
            ''
          else
            ""
        )
        + builtins.readFile source;
    in
    writeShellApplication {
      inherit name text runtimeInputs;
      inheritPath = false;
      extraShellCheckFlags = [ "--external-sources" ];
      passthru.unwrapped = writeText "${name}-unwrapped.sh" ''
        set -euo pipefail
        ${text}
      '';
    };
in
{
  filterBundle = tool "filter-ca-bundle" ./filter-ca-bundle.sh true;
  verifyBundles = tool "verify-ca-bundles" ./verify-ca-bundles.sh true;
  verifyGoExecutables = tool "verify-go-executables" ./verify-go-executables.sh false;
}
