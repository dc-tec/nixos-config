# eMudhra certificate distrust

The `darwin`, `forge`, `forge-dev`, and `chad` configurations exclude the four
roots identified in the [NixOS mitigation](https://github.com/NixOS/nixpkgs/issues/576485).
NSS 3.131.1 removes the three emSign roots. The security overlay also excludes
`Comodo AAA Services root` from package-local CA bundles to block cross-signed
chains. Older NSS bundles receive all four exclusions. The module avoids
blacklisting roots that NSS has already removed because `buildcatrust` rejects
absent blacklist entries.

Nix uses the filtered system bundle through `ssl-cert-file`, including when
`sudo` removes `NIX_SSL_CERT_FILE`.

Darwin also filters Apple's `/etc/ssl/cert.pem` by certificate fingerprint.
Activation preserves the original bundle under
`/var/lib/nixos-trust-backups/apple-cert.pem.before-emudhra`. The root launchd
job `org.nixos.emudhra-ca-filter` reapplies the filter when macOS replaces the
file. It preserves unrelated certificates and records each run in
`/var/log/emudhra-ca-filter.log`.

Activation updates the Nix installer's default-profile CA package without
replacing its other packages. Global pip configuration selects
`/etc/ssl/cert.pem` because Apple's Python includes an independent pip CA
bundle. Activation refuses to overwrite an unrelated global pip configuration.
Project settings, environment variables, and command-line options can override
pip's global setting and require separate verification.

After a macOS update, inspect the filter log and verify both a normal HTTPS
connection and rejection of the incident's direct and cross-signed test
chains. Apple's native trust policy and its command-line bundle are separate;
see [Apple's guidance](https://support.apple.com/en-us/149555).

The minimum fixed Go releases in the policy are 1.26.10 and 1.27.3. Nixpkgs
provides the compilers; the local overlay does not replace their source
archives. Existing Go binaries require a rebuild and installation to receive
the intermediate-key blocklist; changing the development compiler alone does
not update them.

Run the platform-specific security check before building a system generation:

```console
# Apple Silicon macOS
nix build .#checks.aarch64-darwin.emudhra-security --print-build-logs

# On an x86-64 Linux builder
nix build .#checks.x86_64-linux.emudhra-security --print-build-logs
```

The checks inspect SHA-256 fingerprints and OpenSSL rejection records in the
system and package-local bundles. They verify that unrelated roots retain
trust, check Nix's configured CA path, and execute the patched compilers. The
checks also exercise the bundle filter with temporary files, including failed
writes, symlinks, repeated runs, and concurrent bundle replacement.
Build the complete host configuration before applying it. Follow the test,
switch, and rollback procedures in the Forge and Chad guides.

The Nix configuration does not manage the macOS Keychain or Apple trust policy.
Update and verify macOS and Homebrew applications through their own mechanisms.
Applications with embedded CA bundles, containers, development shells, and
independently imported package sets require separate assessment. NixVim and
`nixpkgs-master` use separate inputs and do not inherit the host overlay. An
application that ignores the system bundle does not inherit its distrust
policy. Go 1.25 and externally supplied binaries require separate replacement.

Host activation does not update a VM guest or a container image. Activate each
guest configuration separately. Rebuild container images from their source
inputs and verify the resulting runtime. Preserve existing qualification
fixtures and their evidence until replacement images pass the required checks.

## Implementation

`lib/emudhra-distrust.nix` contains the excluded certificate fingerprints.
`lib/emudhra-policy.nix` selects the NSS blacklist and defines the minimum Go
versions. Host modules, the CA overlay, package reuse guards, and security
checks use that policy. The Go metadata checker receives the same version
thresholds as JSON.

`pkgs/ca-tools` packages the filtering and verification commands with
`writeShellApplication`. They use Bash, OpenSSL, GNU coreutils, awk, grep, and
jq. The launchd job executes the packaged filter directly. The regression
tests run in the Nix checks and use temporary CA bundles.

`overlays/emudhra-security.nix` filters package-local CA bundles. Build
compatibility overrides are separate; see [Package overrides](package-overrides.md).

## Saved Go toolchain defaults

If the workstation's saved `GOTOOLCHAIN` setting selects Go 1.25, remove that
older default after installing a generation with a fixed compiler:

```console
GOTOOLCHAIN=local go env -u GOTOOLCHAIN
go version
```

Outside a project with its own toolchain requirement, `go version` must report
a fixed compiler from the policy. Run project tests with their required patched
compiler. A development-shell or project toolchain selection can override the
host compiler.
