# Forge Machine Configuration

`forge` is the dedicated personal engineering server. It is intended to host
the public forge stack and supporting engineering infrastructure without
becoming a general-purpose homelab or a customer-data platform.

## Status

The host is installed and running NixOS. The first normal boot was verified
with both RAID1 members active, the expected filesystems mounted, and no failed
systemd units. The Disko definition has been applied to the host and remains
destructive when rerun.

Do not run Disko or `nixos-anywhere` before reviewing the disk identities and
storage plan below. Applying it erases all three SSDs.

## Configuration Boundary

The server uses the stable NixOS 26.05 package set and a dedicated minimal
module stack. It does not inherit workstation Home Manager configuration,
desktop theming, impermanence, personal SOPS material, or automatic upgrades.
The host selects `linuxPackages_latest` because current `nixos-anywhere` kexec
images create mdraid metadata that requires Linux 6.19 or newer. An assertion
prevents accidentally selecting an incompatible older kernel. Do not lower
that boundary without also using a compatible custom kexec image and
recreating the arrays.

The initial baseline provides:

- the `forge` hostname;
- a locked `roelc` account with key-only SSH access and passwordless `sudo`;
- a locked root account and disabled root SSH login;
- a default-deny firewall with the WireGuard listener exposed publicly and SSH
  allowed only through `wg0`;
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

## WireGuard Bootstrap

The `wg0` administration interface uses `10.77.0.1/24` and listens on UDP
51820. NixOS generates its private key at `/var/lib/wireguard/forge.key` on the
host with restrictive permissions. Private key material is never stored in
the repository or the Nix store.

`forge.decort.tech` is the public host name and `vpn.decort.tech` is the
WireGuard endpoint. Both records resolve directly to the host's public address.
The VPN record must remain DNS-only in Cloudflare because the standard proxy
does not forward the WireGuard UDP listener.

The first workstation peer is declared as `10.77.0.2/32`. Its handshake and
key-only SSH access through `10.77.0.1` have been verified. SSH is restricted
to the WireGuard interface; provider KVM is the break-glass console path.
Inspect the interface and obtain the server public key with:

```console
sudo wg show wg0
sudo sh -c 'wg pubkey < /var/lib/wireguard/forge.key'
```

An independently stored copy of the WireGuard private key has been verified by
deriving and comparing its public key. Include this key in the broader host
backup and restore procedure as that procedure is established.

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

1. host secret bootstrap and broader remote backups;
2. monitoring;
3. the Nix binary cache;
4. Radicle and Tangled; and
5. OpenBao and identity integration.
