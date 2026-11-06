# Package overrides

The CA overlay changes dependencies throughout the package set. The following
overrides retain qualified upstream outputs or fix build failures while the
system and runtime package bundles keep their distrust policy. These overrides
use the existing flake locks; they do not select older Nixpkgs revisions.

## Shared build compatibility

`modules/build-compatibility.nix` applies
`overlays/build-compatibility.nix` to Darwin, Forge, Forge-dev, and Chad. It is
separate from `overlays/emudhra-security.nix`.

| Override | Purpose |
| --- | --- |
| ShellCheck | Reuse the upstream static checker for offline script analysis. |
| Xen's Pandoc input | Reuse the documentation generator without changing Xen's runtime dependencies. |
| Latest Linux kernel | Reuse the upstream kernel and build module packages from the filtered package set. |

`machines/chad/package-overrides.nix` applies the same kernel treatment to
Chad's Linux 6.12 selection. It does not duplicate the shared tool overrides.

Forge and Chad use QEMU/KVM. `modules/nixos/server/kvm-libvirt.nix` disables the
unused Xen driver throughout each host's package set. This covers the daemon,
VM helper scripts, and native bridge setup commands that reference
`pkgs.libvirt` directly. It removes Xen's Open vSwitch dependency, whose
timing-sensitive tests fail on the CI runners.

## Darwin package overrides

`machines/darwin/package-overrides.nix` contains the workstation's package reuse
guards and Python build fixes.

| Override | Constraint |
| --- | --- |
| Kubescape, Jujutsu, Just, Devenv, pre-commit | Reuse only the qualified package versions. Wrappers select filtered CA bundles. Kubescape also requires a fixed Go compiler. |
| FFmpeg manual pages | The upstream manual-page output must match the selected executable version. Executables and libraries stay filtered. |
| DeepDiff | The upstream build must match both the Python interpreter and the qualified DeepDiff version. |
| Clippy, rustfmt, GHC | Reuse the upstream toolchain outputs selected by the lock. |

The security check inspects every output of the reused application packages. It
rejects CA bundles in their closures and Go executables built before the policy's
fixed releases. Wrappers set `SSL_CERT_FILE` and `REQUESTS_CA_BUNDLE` when the
caller has not set them. These checks cover the listed reused applications; they
do not establish trust behavior for arbitrary packages or embedded verifiers.

The terminal-background renderer imports upstream ImageMagick only to render a
local font into a static PNG during the build.

`modules/darwin/packages.nix` selects stable Azure CLI because the pinned unstable
package depends on Fabric with unsupported Invoke 3. Its wrapper selects the
filtered CA bundle when the caller has not supplied a bundle path.

## Python build fixes

Black 26.5.1 and aiohttp 3.14.3 use separate pytest temporary directories. This
prevents cleanup failures caused by the shared `/tmp` directory and keeps Unix
socket paths short.

For aiohttp 3.14.3, the
[multiple-event-loop test](https://github.com/aio-libs/aiohttp/blob/v3.14.3/tests/test_connector.py)
leaks a socket when its mocked TLS failure runs while port 443 is occupied. The
local patch closes the socket in that failure path. The upstream test selection
remains enabled.

## Updating or removing an override

When changing a relevant flake input, review the version guard, retained outputs,
and runtime CA assumptions. Preserve required outputs, including documentation,
until dependent builds finish.

Remove a compatibility override after the direct upstream package builds and the
platform security check passes. Compare affected host derivations and review the
resulting package changes before activation. Keep security policy changes
separate from changes to build compatibility.

Darwin excludes the insecure Radicle CLI and TUI. Forge's Radicle and Tangled
services are removed; see the retirement procedure in
[the Forge guide](machine-forge.md).
