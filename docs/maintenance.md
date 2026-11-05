# Maintenance tasks

## System generations

List system generations and remove obsolete generations with:

```console
nix-env --profile /nix/var/nix/profiles/system --list-generations
nh clean --all
```

Retain a working rollback generation during system updates.

## Mac development storage

Go builds share `~/Library/Caches/go-build` and `~/go/pkg/mod` across worktrees
and development shells. Set `GOCACHE` or `GOMODCACHE` per run only when a test
requires an isolated cache. Remove that cache after a successful test and retain
the test result. Keep the shared caches warm for normal development.

Homebrew removes cached downloads older than seven days during cleanup. Package
operations run its full cleanup at most once every seven days. This policy does
not run a scheduled background job.

After a successful test campaign, retain the required reports, source identity,
and qualification artifacts, then remove the campaign's runnable environment.
The repository's test harness owns that teardown. Identify containers and
volumes by their recorded IDs and verify ownership before removal. Preserve
failed or unfinished fixtures until the investigation is complete. A paused
task still owns its environment.

Reuse an existing checkout when concurrent edits do not require another
worktree. Before removing a completed worktree, preserve uncommitted source,
unpushed commits, and required ignored artifacts. Worktrees already share Git
objects, but each checkout can accumulate separate build output.

For temporary source snapshots on the same APFS volume, use macOS's native
copy-on-write copy to share disk blocks while keeping later writes independent:

```console
/bin/cp -cR -p source snapshot
```

Do not use hard links for mutable build or source files. Measure free space with
`df -h /System/Volumes/Data`; directory totals can count shared clone data more
than once. Review `docker system df` separately. Prune build cache only while
builds are idle, and inspect images and volumes before deleting them.

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
