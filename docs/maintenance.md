# Maintenance tasks

## System generations

List system generations and remove obsolete generations with:

```console
nix-env --profile /nix/var/nix/profiles/system --list-generations
nh clean --all
```

Retain a working rollback generation during system updates.

## Security and package overrides

See [eMudhra certificate distrust](emudhra-hardening.md) for CA policy, compiler
requirements, macOS bundle management, verification, and coverage limits.
See [Package overrides](package-overrides.md) for build compatibility exceptions
and the conditions for removing them.

## Build and activation

Update and validate the independent NixVim flake before pinning its revision in
this repository. Its Linux and Darwin checks are separate from the host checks.

Builds do not activate a generation. Review package changes and retain the
previous host generation before switching. Darwin activation also updates
Homebrew packages and runs Home Manager activation.

Use the qualified checkout or its built store path for activation. Verify the
flake path before using an `nh` alias; another checkout can contain an older
configuration. Host activation does not update a VM guest or container image.

Forge runs the `forge-dev` development VM. Before testing, switching, or
rebooting Forge, coordinate with active development or migration sessions.
Host activation can restart VM or network services. Confirm that guest fixtures
have reached a safe checkpoint before proceeding.

Chad uses a separate Nixpkgs input and kernel selection. Verify encrypted-storage
unlock, pool import, networking, and libvirt after a reboot. Keep ZFS pool
feature upgrades separate from a system update.

Follow the host-specific test, switch, and rollback procedures in the
[Forge](machine-forge.md) and [Chad](machine-chad.md) guides.
