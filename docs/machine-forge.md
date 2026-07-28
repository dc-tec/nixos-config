# Forge Machine Configuration

`forge` is the dedicated personal engineering server. It is intended to host
the public forge stack and supporting engineering infrastructure without
becoming a general-purpose homelab or a customer-data platform.

## Status

The host has a buildable server baseline and a Disko storage definition based
on inventory collected from the temporary Debian installation. The Disko
definition is destructive and has not been applied yet.

Do not run Disko or `nixos-anywhere` before reviewing the disk identities and
storage plan below. Applying it erases all three SSDs, including the temporary
Debian installation.

## Configuration Boundary

The server uses the stable NixOS 26.05 package set and a dedicated minimal
module stack. It does not inherit workstation Home Manager configuration,
desktop theming, impermanence, personal SOPS material, or automatic upgrades.

The initial baseline provides:

- the `forge` hostname;
- a locked `roelc` account with key-only SSH access and passwordless `sudo`;
- a locked root account and disabled root SSH login;
- a default-deny firewall with public SSH as the only open port;
- fail2ban, SMART monitoring, SSD trimming, and compressed swap;
- a small set of operational tools; and
- scheduled Nix garbage collection and store optimisation.

The public interface is `enp1s0f0` and receives its IPv4 configuration through
DHCP. The second Intel I350 interface is not configured.

## Intended Storage Shape

The observed machine boots through legacy BIOS and contains three Micron 1100
SATA SSDs. The Disko layout uses stable WWN device paths and creates:

- a BIOS GRUB partition on each durable disk;
- a 1 GiB ext4 `/boot` mdadm RAID1 array using metadata 1.0;
- an ext4 `/` mdadm RAID1 array using the remaining space; and
- an independent ext4 `/cache` filesystem on the third SSD.

GRUB is installed to both durable SSDs. `/cache` uses `nofail`, because loss of
reconstructible cache data must not prevent the server from booting.

## Captured Inventory

The configuration was derived from this read-only inventory:

```console
Firmware: BIOS
Public NIC: enp1s0f0 (DHCP)
Durable disk A: /dev/disk/by-id/wwn-0x500a07511756b6c8
Durable disk B: /dev/disk/by-id/wwn-0x500a07511756abda
Cache disk:     /dev/disk/by-id/wwn-0x500a075115a7a32f
```

Before installation, compare all three paths against a fresh `lsblk` and
`/dev/disk/by-id` listing. Device names such as `/dev/sda` are not used as
installation identities.

## Installation Gate

The temporary Debian image does not include `sudo`, and the `roelc` account has
no administrative group membership. Before installation, use the temporary
root password to install `sudo` and grant `roelc` passwordless `sudo`. This
bootstrap state is erased with Debian; the resulting NixOS system retains
key-only SSH, disables root SSH login, and grants passwordless `sudo` only to
the configured `wheel` user.

Evaluate the system and generated Disko script without applying them. These
commands work from the Apple Silicon workstation:

```console
nix eval --raw .#nixosConfigurations.forge.config.system.build.toplevel.drvPath
nix eval --raw .#nixosConfigurations.forge.config.system.build.diskoScript.drvPath
```

Build both derivations on an x86-64 Linux builder or in CI:

```console
nix build .#checks.x86_64-linux.nixos-forge
nix build .#checks.x86_64-linux.forge-disko
```

An x86-64 Linux host can additionally exercise the Disko layout inside a VM:

```console
nix run .#nixos-anywhere -- --flake .#forge --vm-test
```

After those checks and a final disk-identity review, run the pinned installer
from this repository. This command is intentionally documented with a
placeholder target and must not be copied blindly:

```console
nix run .#nixos-anywhere -- \
  --flake .#forge \
  --build-on-remote \
  --target-host roelc@FORGE_ADDRESS
```

The explicit remote build is required when invoking the installer from the
Apple Silicon workstation because the target closure is x86-64 Linux.

## Deferred Service Slices

Application services are intentionally outside this first host slice. Add them
independently after the base system has booted and remote recovery is proven:

1. WireGuard administration and backup transport;
2. host secret bootstrap;
3. monitoring;
4. the Nix binary cache;
5. Radicle and Tangled; and
6. OpenBao and identity integration.
