{
  system,
  hosts,
}:
let
  pkgs = (builtins.head hosts).pkgs;
  inherit (pkgs) lib;
  policy = import ../lib/emudhra-policy.nix { inherit lib; };
  tools = pkgs.callPackage ../pkgs/ca-tools { };
  bundles = lib.unique (
    lib.concatMap (host: [
      (toString host.config.environment.etc."ssl/certs/ca-certificates.crt".source)
      "${host.pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
    ]) hosts
  );
  compilers = lib.unique (
    lib.concatMap (
      host: [ host.pkgs.go_1_26 ] ++ lib.optional (host.pkgs ? go_1_27) host.pkgs.go_1_27
    ) hosts
  );
  cachedPackages =
    if system == "aarch64-darwin" then
      lib.unique (
        lib.concatMap (
          host:
          lib.concatMap
            (
              name:
              let
                package = host.pkgs.${name};
              in
              lib.optional (package ? emudhraCachedPackage) package.emudhraCachedPackage
            )
            [
              "kubescape"
              "jujutsu"
              "just"
              "devenv"
              "pre-commit"
            ]
        ) hosts
      )
    else
      [ ];
  cachedClosure = pkgs.closureInfo {
    rootPaths = lib.concatMap (package: map (output: package.${output}) package.outputs) cachedPackages;
  };
  validHost =
    host:
    builtins.elem "Comodo AAA Services root" host.config.security.pki.caCertificateBlacklist
    && host.config.nix.settings.ssl-cert-file == "/etc/ssl/certs/ca-certificates.crt"
    && policy.isFixedGo host.pkgs.go.version
    && policy.isFixedGo host.pkgs.go_1_26.version
    && (!(host.pkgs ? go_1_27) || policy.isFixedGo host.pkgs.go_1_27.version);
in
assert import ./test-emudhra-policy.nix { inherit lib policy; };
assert lib.all validHost hosts;
pkgs.runCommand "emudhra-security-${system}"
  {
    nativeBuildInputs = [
      pkgs.bash
      pkgs.coreutils
      pkgs.gawk
      pkgs.gnugrep
      pkgs.jq
      pkgs.openssl
    ];
    policy = builtins.toJSON policy.roots;
    goPolicy = builtins.toJSON policy.minimumGoVersions;
    passAsFile = [
      "policy"
      "goPolicy"
    ];
  }
  ''
    ${lib.getExe tools.verifyBundles} "$policyPath" ${lib.escapeShellArgs bundles}
    TEST_CA_BUNDLE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt \
      FILTER_CA_BUNDLE_SCRIPT=${tools.filterBundle.unwrapped} \
      FILTER_CA_BUNDLE_COMMAND=${lib.getExe tools.filterBundle} \
      VERIFY_CA_BUNDLES_COMMAND=${lib.getExe tools.verifyBundles} \
      bash ${./test-filter-ca-bundle.sh}
    GO_POLICY="$goPolicyPath" \
      VERIFY_GO_COMMAND=${lib.getExe tools.verifyGoExecutables} \
      bash ${./test-go-verification.sh}
    ${lib.concatMapStringsSep "\n" (compiler: ''
      actual="$(${compiler}/bin/go version)"
      case "$actual" in
        "go version go${compiler.version} "*) printf '%s\n' "$actual" ;;
        *) echo "Unexpected compiler version: $actual" >&2; exit 1 ;;
      esac
    '') compilers}
    ${lib.optionalString (cachedPackages != [ ]) ''
      while IFS= read -r packagePath; do
        if [[ "$packagePath" == *-cacert-* ]] \
          || [ -e "$packagePath/etc/ssl/cert.pem" ] \
          || [ -e "$packagePath/etc/ssl/certs/ca-bundle.crt" ] \
          || [ -e "$packagePath/etc/ssl/certs/ca-certificates.crt" ]; then
          echo "Cached Go package carries a CA bundle: $packagePath" >&2
          exit 1
        fi
      done < ${cachedClosure}/store-paths
    ''}
    ${lib.optionalString (cachedPackages != [ ]) ''
      ${lib.getExe tools.verifyGoExecutables} ${pkgs.go_1_26}/bin/go ${cachedClosure}/store-paths "$goPolicyPath"
    ''}
    touch "$out"
  ''
