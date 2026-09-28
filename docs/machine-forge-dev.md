# Forge Development VM

`forge-dev` is an isolated, persistent NixOS development workstation on the
Forge server. It is intended to move Linux builds, repository worktrees and
tool caches off the macOS workstation without mixing development credentials
or agent processes into the public Forge services.

## Design

The guest is a normal NixOS system built as an EFI qcow2 image and run by
QEMU/KVM through libvirt. It is not a `nixos-rebuild build-vm` test runner: the
guest owns persistent disks, boots independently and can later be updated with
the regular NixOS deployment flow.

The initial resource budget leaves capacity for the existing Forge services:

| Resource | Allocation |
| --- | --- |
| vCPU | 6 of 8 threads |
| Memory | 20 GiB of 31 GiB |
| Root disk | 32 GiB, sparse qcow2 |
| Durable data disk | 100 GiB, sparse qcow2 |
| Disposable cache disk | 120 GiB, sparse qcow2 |

The VM uses `10.78.0.10/24` behind the host-only `br-dev` bridge. Forge
provides outbound NAT. SSH is proxied only from WireGuard
`10.77.0.1:2222`; the workstation does not need a route to the guest subnet.

## Encryption Boundary

The guest root disk and durable data disk live inside the 150 GiB sparse LUKS2
container at:

```text
/var/lib/forge-vms/forge-dev.luks
```

The container must be unlocked manually after a Forge reboot. The VM is not
configured for autostart because it must never fall back to writing durable
state outside the encrypted mount. This protects the powered-off guest disks,
including its Nix store, home directory, Git credentials and Docker state.
It does not protect a running guest from the Forge root administrator.

The cache disk lives under `/cache/forge-vms/forge-dev` and is deliberately
unencrypted and reconstructible. Do not place credentials, worktrees or
authoritative state there.

The guest also has a persistent software TPM 2.0 using QEMU's `tpm-crb` model
and libvirt-managed `swtpm`. Its state is stored under the encrypted durable
VM directory, so the TPM identity survives guest reboots and domain
redefinition without leaking onto the host root filesystem. This is suitable
for TPM integration, sealing and measured-boot experiments. It is not a
hardware root of trust: a Forge root administrator can still inspect or alter
the emulator and a running guest.

The guest's Ed25519 SSH host key is stored on the encrypted durable data disk
under `/srv/dev/ssh`. Replacing the rebuildable root disk therefore does not
change the SSH identity. The disk initializer carries the temporary first-boot
key into that directory when it mounts a blank data disk for the first time.

## Host Deployment

First evaluate both configurations without building them:

```console
nix eval --raw .#nixosConfigurations.forge.config.system.build.toplevel.drvPath
nix eval --raw .#nixosConfigurations.forge-dev.config.system.build.toplevel.drvPath
nix eval --raw .#nixosConfigurations.forge-dev.config.system.build.images.qemu-efi.drvPath
```

Test the host generation before making it persistent:

```console
nix run nixpkgs#nixos-rebuild -- test \
  --flake .#forge \
  --build-host roelc@10.77.0.1 \
  --target-host roelc@10.77.0.1 \
  --elevate sudo \
  --use-substitutes \
  --print-build-logs
```

Verify that the public services remain healthy and that the new host surfaces
exist:

```console
ssh roelc@10.77.0.1 systemctl status libvirtd.service forge-dev-ssh-proxy.socket
ssh roelc@10.77.0.1 ip address show br-dev
ssh roelc@10.77.0.1 sudo virsh --connect qemu:///system list --all
```

After acceptance, repeat the rebuild with `switch`.

## One-time Bootstrap

Initialize the encrypted host storage interactively. This command creates and
formats only `/var/lib/forge-vms/forge-dev.luks`; it refuses to overwrite an
existing container:

```console
ssh -t roelc@10.77.0.1 sudo forge-dev-storage-initialize
```

The initializer creates the first LUKS2 keyslot with the primary passphrase.
Before placing data in the filesystem, add the separately stored recovery
passphrase to a second keyslot:

```console
ssh -t roelc@10.77.0.1 \
  sudo cryptsetup luksAddKey /var/lib/forge-vms/forge-dev.luks
```

Enter the primary passphrase when asked for an existing passphrase, then enter
the recovery passphrase as the new passphrase. Confirm that two keyslots are
enabled with `cryptsetup luksDump`; its output does not contain either
passphrase. Lock the storage and test `forge-dev-storage-unlock` once with each
passphrase before continuing:

```console
ssh roelc@10.77.0.1 sudo forge-dev-storage-lock
ssh -t roelc@10.77.0.1 sudo forge-dev-storage-unlock
ssh roelc@10.77.0.1 sudo forge-dev-storage-lock
ssh -t roelc@10.77.0.1 sudo forge-dev-storage-unlock
```

Only after both keyslots work, create a LUKS2 header backup in Forge's tmpfs,
copy it directly into the prepared encrypted APFS disk image, and compare its
SHA-256 checksum on both sides. Replace the destination volume name below with
the actual mounted image path:

```console
ssh roelc@10.77.0.1 sudo cryptsetup luksHeaderBackup \
  /var/lib/forge-vms/forge-dev.luks \
  --header-backup-file /run/forge-dev.luks.header
ssh roelc@10.77.0.1 sudo chown roelc:users /run/forge-dev.luks.header
ssh roelc@10.77.0.1 sudo chmod 0400 /run/forge-dev.luks.header
ssh roelc@10.77.0.1 sha256sum /run/forge-dev.luks.header
scp roelc@10.77.0.1:/run/forge-dev.luks.header \
  "/Volumes/Forge LUKS Header/forge-dev.luks.header"
shasum -a 256 "/Volumes/Forge LUKS Header/forge-dev.luks.header"
ssh roelc@10.77.0.1 rm /run/forge-dev.luks.header
```

The header backup contains keyslot metadata and must stay encrypted at rest.
Restoring it replaces the current header and keyslots, so resolve and verify
the exact LUKS container path before using `cryptsetup luksHeaderRestore`.
Neither normal unlock nor recovery requires storing a passphrase on Forge.

Build the guest image directly in Forge's Nix store. From a clean, committed
checkout, use the explicit Linux check output:

```console
nix build \
  --eval-store auto \
  --store ssh-ng://roelc@10.77.0.1 \
  --no-link \
  --print-out-paths \
  .#checks.x86_64-linux.forge-dev-image
```

During local development, use a `path:` URL so new untracked configuration
files are included. Keep evaluation in the workstation store: otherwise Nix
performs thousands of remote-store calls and may upload the complete dirty
source tree, including the repository's large Git object store.

```console
image="$(nix build \
  --eval-store auto \
  --store ssh-ng://roelc@10.77.0.1 \
  --no-link \
  --print-out-paths \
  "path:$PWD#nixosConfigurations.forge-dev.config.system.build.images.qemu-efi")"
ssh roelc@10.77.0.1 sudo forge-dev-vm-bootstrap "$image"
```

The bootstrap command copies the immutable root image into encrypted storage,
grows it to 32 GiB, creates the data and cache disks, defines the libvirt
domain and starts it. It also creates the persistent TPM state directory inside
the encrypted mount. It does not replace an existing root or data disk.

Add this workstation entry to `~/.ssh/config`:

```sshconfig
Host forge-dev
  HostName 10.77.0.1
  Port 2222
  User dev
  IdentityFile ~/.ssh/id_ed25519
  IdentitiesOnly yes
```

The first SSH login may report that `/srv/dev/home/dev` does not exist because
the guest disks are still blank. Initialize only the two fixed virtio disks:

```console
ssh -t forge-dev sudo /run/current-system/sw/bin/forge-dev-initialize
```

Reconnect after initialization. The development home, projects and Docker
state are then on the encrypted durable disk.

Confirm the TPM 2.0 device from the guest with:

```console
test -c /dev/tpmrm0
tpm2_getcap properties-fixed
```

## Daily Operation

After a Forge reboot, unlock the storage and start the VM:

```console
ssh -t roelc@10.77.0.1 sudo forge-dev-storage-unlock
cmux ssh forge-dev --no-forward-agent
```

Agent and Unix-domain socket forwarding are disabled. Provision a dedicated
GitHub credential inside the encrypted guest instead of forwarding the
workstation SSH agent. The `dev` account cannot obtain general sudo access, but
Docker group membership is root-equivalent inside this isolated guest.

cmux 0.64.22 uses an SSH remote TCP forward for its authenticated relay. The
guest therefore permits remote TCP forwarding only; local TCP, agent,
StreamLocal, X11 and tunnel forwarding remain disabled. `GatewayPorts no`
forces the relay listener onto guest loopback. Native Mac `ssh -L` access stays
disabled until its destinations and `PermitOpen` policy are defined.

Before deliberately detaching the encrypted storage, shut down the VM and lock
it with:

```console
ssh roelc@10.77.0.1 sudo forge-dev-storage-lock
```

The lock command refuses to unmount storage if the guest does not shut down
cleanly within 90 seconds.

## Interactive Shell Baseline

New `dev` sessions use zsh with Starship, completion, autosuggestions, syntax
highlighting, persistent history and integrations for direnv, fzf and zoxide.
The guest also includes a small workstation-style CLI baseline: `bat`, `eza`,
`yazi`, `lazygit`, `jj`, the workstation Nixvim package, `tldr`, `atac`,
`comma` and common inspection utilities.

This baseline is intentionally separate from repository toolchains. Nixvim's
bundled language servers and helpers are treated as guest-wide editor
infrastructure. Repository runtimes, generators, linters and test tools should
still come from each repository's devenv. Long-lived shell persistence through
tmux is not part of the initial shell configuration.

## Pilot Workloads

Start with SecretSpec because its `devenv` definition owns the multi-language
toolchain and exercises the remote Nix store without requiring Kubernetes:

```console
mkdir -p ~/projects
cd ~/projects
git clone https://github.com/adfinis-forks/secretspec.git
cd secretspec
devenv test
```

Then clone a clean OpenBao Operator worktree. Its external prerequisites are
installed in the guest, while repository-managed tools remain pinned by the
project:

```console
cd ~/projects
git clone https://github.com/dc-tec/openbao-operator.git
cd openbao-operator
make bootstrap
make doctor
make test-ci
```

Use `make ci-core` only after the first three checks pass. It builds and scans
multiple container images and is the useful stress test for the VM's CPU,
memory, Docker storage and cache behavior. Kind-based E2E is a later test, not
part of the initial acceptance gate.

Record wall time, peak memory, durable-disk growth and cache-disk growth for
both repositories before deciding whether to change the VM allocation or move
more workstreams.

## Recovery

The LUKS passphrase is not stored in Nix, the repository or the Forge host. Keep
it in the password manager. The VM is initially a migration aid rather than a
backup authority: repository branches must still be published, and important
unpublished work needs an explicit backup policy before the Mac copy is
removed.

The root disk is replaceable from the `forge-dev-image` output. The durable
data disk, including the SSH host key, is not replaceable and is not included
in the existing Forge Restic job. The cache disk can be deleted and recreated
at any time.
