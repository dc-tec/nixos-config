# Chad lab host

Chad is a headless KVM/libvirt host on the LAN. Its configuration uses the
`nixpkgs-chad` input, which tracks NixOS 26.05 independently of Forge and the
workstations. The system state version remains `24.05`.

## Host configuration

- CPU: AMD Ryzen 5 2600, with 6 cores and 12 threads.
- Memory: 64 GB installed, approximately 62 GiB available to Linux.
- Network: static address `10.0.10.183/24` on `br0`, with `enp27s0` as the bridge
  member. The default gateway is `10.0.10.1` through `br0`. DHCP is disabled.
- DNS servers: `1.1.1.1` and `1.0.0.1`.
- Administration: SSH as `roelc` on TCP port 22, with `doas` for privileged
  commands. The host firewall permits port 22.
- Virtualization: KVM and libvirt. The desktop and Docker daemon are disabled.
- Storage: encrypted SSD-only `rpool` across the two existing 250 GB SSDs,
  with no disk redundancy. The 1 TB HDD contains a separate encrypted `bulk`
  pool. Both pools use `ashift=12` and the `openzfs-2.4-linux` compatibility set.
- ZFS ARC: capped at 4 GiB. Disk swap is disabled; zram remains enabled.

The disk layout is declared in `machines/chad/disko.nix` using persistent WWN
identifiers. The boot SSD has a 1 GiB EFI partition. Both SSDs provide space to
`rpool`; this is a stripe, so loss of either SSD loses the pool.

| Device | Persistent identifier | Use |
| --- | --- | --- |
| Samsung SSD 850 EVO 250 GB | `wwn-0x5002538d42594eae` | EFI partition and `rpool` |
| Samsung SSD 850 EVO 250 GB | `wwn-0x5002538d426746d4` | `rpool` |
| Seagate ST1000DM010 1 TB | `wwn-0x5000c500a22f749d` | `bulk` |

Libvirt state and active VM disks use `rpool/local/lab`, mounted at
`/cache/var/lib/libvirt` before stage 2 creates its bind mount at
`/var/lib/libvirt`. VM images use the `images` subdirectory. SSH host keys remain
under `/data/etc/ssh`.
All active lab storage stays on SSD. The HDD is for disposable exports,
archives, and installation media; it is not a backup of the host.

The HDD is excluded from boot filesystem dependencies and automatic pool
imports. After boot, unlock and mount it when required:

```shell
doas chad-bulk-open
```

Enter the `bulk` passphrase at the terminal prompt. The command imports the
pool without mounting datasets, loads its encryption key, and mounts
`bulk/data` at `/bulk`. To close it after use:

```shell
doas zpool export bulk
```

Local account passwords are locked. SSH keys provide administration, and
`doas` permits privileged commands for `roelc`. Automatic upgrades and Nix
garbage collection are disabled. Retain a previous generation after future
upgrades until encrypted-pool import, networking, and libvirt pass boot checks.
The fresh installation does not retain generations from the previous pool.

## Lab Access Network

Chad is a peer of the Forge WireGuard hub, so the administration workstation
can reach the lab host and its guest networks away from the LAN. Chad dials out
with a 25-second keepalive; the home network needs no inbound port.

| Item | Value |
| --- | --- |
| Chad tunnel address | `10.77.0.3/24` |
| Hub endpoint | `vpn.decort.tech:51820` |
| Routed lab guest range | `10.79.0.0/22` |
| Private key | `/var/lib/wireguard/chad.key`, persisted under `/data` |

The key is generated on Chad at first activation. Add its public key to
`chadPublicKey` in `machines/forge/wireguard.nix` and deploy Forge:

```shell
doas sh -c 'wg pubkey < /var/lib/wireguard/chad.key'
```

The firewall accepts tunnel traffic from the workstation address `10.77.0.2`
only: SSH to Chad, lab DNS, and forwarding to lab guests on TCP ports 22, 443,
5000, 6443, 8200, 8443, and 50000. The hub's own address cannot open
connections to Chad or the lab. Lab guests may reach the internet through
masquerading on `br0`, but not private LAN ranges.

Lab networks use libvirt's `open` forward mode with bridges named `lab-*`, so
this firewall owns their forwarding, DHCP, and DNS rules. Libvirt NAT networks
reject connections from the tunnel and remain local-only. The lab repository
defines the guest networks; this host defines the policy for `10.79.0.0/22`.
SSH keeps `DisableForwarding yes`; the LAN path remains available when Forge is
down.

## Rebuild verification (2026-09-28)

The fresh installation booted NixOS `26.05.20260927.cf5e765`, Linux `6.12.111`,
and OpenZFS `2.4.4`. Remote ZFS unlock and normal key-based SSH both succeeded.
The static address appeared only on `br0`, both DNS servers were retained,
DNS resolution worked, and no system units failed.

`rpool` contains only the two SSDs and reports 462 GiB raw capacity, with
approximately 444.5 GiB dataset availability after installation. Its datasets
inherit encryption. Both `/cache/var/lib/libvirt` and `/var/lib/libvirt` resolve
to `rpool/local/lab`. The running ARC maximum is 4 GiB; swap uses only zram.

The 928 GiB HDD pool was exported before reboot and remained unimported after
host startup. Before reboot, a separate import confirmed that its key was
unavailable and `bulk/data` used `canmount=noauto`. Physical HDD removal and
interactive use of `chad-bulk-open` remain untested.

Libvirt reports KVM domain capabilities. No guests are defined. These host
checks do not validate guest boot or lab workloads. Backups remain deferred.

## Upgrade procedure

1. Update only Chad's package input when a newer revision is required:

   ```shell
   nix flake update nixpkgs-chad
   ```

2. Build the `nixosConfigurations.chad.config.system.build.toplevel` output on
   an `x86_64-linux` host. Check the resulting SSH configuration, filesystems,
   network units, kernel, and OpenZFS version before activation.
3. On Chad, from a checkout containing the reviewed configuration and lock file,
   install the new boot entry without switching the running services:

   ```shell
   doas nixos-rebuild boot --flake .#chad
   ```

4. Reboot, then enter the ZFS passphrase through the initramfs SSH service as
   described below. The physical console remains available for recovery.
5. After unlocking, verify the host:

   ```shell
   nixos-version
   uname -r
   zpool status -x rpool
   ip -brief address show br0
   ip route
   systemctl --failed
   virsh -c qemu:///system list --all
   ```

   Verify SSH from another machine and check that the persistent directories
   still resolve to their existing `/cache` and `/data` locations. A successful
   build does not validate boot, pool import, or network recovery.

If boot fails, select the previous NixOS generation in the systemd-boot menu.
Do not upgrade ZFS pool feature flags as part of the operating-system upgrade;
the previous generation must retain access to the pool.

## Remote ZFS unlock

The initramfs loads the `r8169` driver and assigns `10.0.10.183/24` to the NIC
with MAC address `00:d8:61:0e:e4:87`. It uses gateway `10.0.10.1` and DNS servers
`1.1.1.1` and `1.0.0.1`. Keep this static address reserved or excluded from the
DHCP allocation range. The initramfs uses only the physical NIC; it does not
create `br0`. Before stage 2 creates the bridge, its service removes any IPv4
address left on `enp27s0`. Stage 2 then assigns the static address to `br0`.
This prevents a duplicate connected route through the physical NIC.

From the configured laptop, connect after reboot:

```shell
TERM=xterm ssh -a -t -p 2222 root@chad
```

This uses the existing `chad` SSH alias and its client key. If the alias is not
available, use the IP address and select the authorized client key:

```shell
TERM=xterm ssh -a -t -p 2222 -i ~/.ssh/roelc_gh root@10.0.10.183
```

Enter the ZFS passphrase in the SSH prompt. The server forces the
`systemd-tty-ask-password-agent --watch` command and disables SSH forwarding.
The connection closes when boot continues. Reconnect as `roelc` on port 22
after the main system starts. The initramfs SSH service is not available after
boot.

The unlock service has a dedicated Ed25519 host key. Its fingerprint is:

```text
SHA256:d0fKLFVOeUd2QFioxlE6RqMgPkcX/ZriA8RDBp3kYqA
```

The private key is stored at `/data/etc/ssh/initrd_ssh_host_ed25519_key` and
injected into the boot image when the boot entry is installed on Chad. It must
be available on the unencrypted boot partition. The EFI partition uses
`umask=0077` to restrict access to root. Do not reuse the normal SSH host key
for this purpose. The ZFS passphrase is not stored in the boot image or the
repository.

For a fresh installation, generate this dedicated key on Chad before installing
the boot entry, and record its new fingerprint:

```shell
doas ssh-keygen -t ed25519 -N '' -C chad-initrd \
  -f /data/etc/ssh/initrd_ssh_host_ed25519_key
```

Use this command only when the key does not already exist. Configuration follows
the [NixOS remote unlock guidance](https://wiki.nixos.org/wiki/Remote_disk_unlocking)
with systemd in the initramfs.

## Fresh installation

The disk configuration destroys existing data on the three listed internal
disks. Check each WWN, model, and capacity in an independent installer before
running Disko. The attached USB device is not an installation target.

1. Boot a RAM-based NixOS installer and verify SSH access, the static address,
   the gateway, and DNS. Confirm that its root filesystem is `tmpfs`, no target
   disk is mounted, and no ZFS pool is imported.
2. Build and copy the pinned `nixosConfigurations.chad.config.system.build.toplevel`
   and `nixosConfigurations.chad.config.system.build.diskoScript` outputs to the
   installer. Keep a copy outside Chad before erasing its disks.
3. Enter and confirm the new passphrase through a terminal with hidden input.
   Store it only in `/run/chad-install/pool.key`, owned by root with mode `0600`.
   Both pools use this passphrase but have independent encryption roots.
4. Run the built Disko script. It creates and mounts the SSD filesystems under
   `/mnt`, creates the HDD pool, and sets both pools' key locations to `prompt`.
   The passphrase file is required only during pool creation.
5. Before installing the boot entry, place the normal SSH host keys and the
   dedicated initramfs SSH host key under `/mnt/data/etc/ssh`. Preserve existing
   keys when maintaining host identity, or generate new keys and verify their
   fingerprints through a trusted channel.
6. Install the built system with `nixos-install --root /mnt --system <store-path>
   --no-root-passwd`. Export `bulk` and delete the RAM passphrase file.
7. Verify the EFI boot entry, SSD pool membership, dataset mounts, encryption
   properties, and static network configuration. Reboot and unlock `rpool`
   through port 2222.
8. Complete the host checks in the upgrade procedure. Confirm that `bulk`
   remains unimported and that the host boots without an HDD unlock prompt.

A completed build does not validate the installation, remote unlock, or boot.
The storage rebuild removes all prior host generations and their rollback paths.
