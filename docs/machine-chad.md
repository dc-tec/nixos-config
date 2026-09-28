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
- Storage: the existing encrypted `rpool`, with separate root, Nix store,
  cache, and data datasets. The pool has three single-device top-level vdevs
  and no disk redundancy.

The configuration keeps the deployed bind-mount locations under `/cache` and
`/data`. In particular, libvirt uses `/cache/var/lib/libvirt`, and the SSH host
keys remain under `/data/etc/ssh`. The upgrade does not move persistent data.
Root-dataset rollback is disabled during this migration, so rebooting does not
discard files from the existing root dataset. Local account passwords remain
unchanged through `users.mutableUsers = true`.

Automatic upgrades and automatic Nix garbage collection are disabled. Upgrade
the host manually and retain a previous generation until the new kernel,
encrypted-pool import, networking, and libvirt have passed the boot checks.

## Boot verification (2026-09-28)

Chad completed a reboot on NixOS `26.05.20260927.cf5e765`, Linux `6.12.111`,
and OpenZFS `2.4.4`. Remote ZFS unlock completed, and normal SSH returned without
console repairs. The address was present only on `br0`, both configured DNS
servers were retained, DNS resolution worked, and no system units had failed.
The pool was healthy, and the existing persistence mounts used their original
datasets.

Libvirt returned KVM domain capabilities. No guests remain defined; guest boot
and workload tests are separate from these host checks. The NixOS 24.11
generation `336` remains available for rollback. Backups remain deferred.

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

## Original installation reference

The commands below describe the original installation and destroy existing
partitions. They are not part of the host upgrade. Device names can change;
identify disks by their persistent IDs before any new installation.

```shell
diska=/dev/sda
sudo parted "$diska" -- mklabel gpt
sudo parted "$diska" -- mkpart primary 512MiB -8GiB # zfs
sudo parted "$diska" -- mkpart primary linux-swap -8GiB 100% # swap
sudo parted "$diska" -- mkpart ESP fat32 1MiB 512MiB # boot
sudo parted "$diska" -- set 3 esp on

sudo mkswap -L swap "${diska}2"
sudo mkfs.fat -F 32 -n EFI "${diska}3"

diskb=/dev/sdb
sudo parted "$diskb" -- mklabel gpt
sudo parted "$diskb" -- mkpart primary 1MiB -8GiB # zfs

diskc=/dev/sdc
sudo parted "$diskc" -- mklabel gpt
sudo parted "$diskc" -- mkpart primary 1MiB -8GiB # zfs

zpool create -O mountpoint=none -O encryption=aes-256-gcm -O keyformat=passphrase rpool "${diska}1" "${diskb}1" "${diskc}1"

zfs create -p -o mountpoint=legacy rpool/local
zfs create -p -o mountpoint=legacy rpool/safe
zfs create -p -o mountpoint=legacy rpool/local/root

zfs snapshot rpool/local/root@blank
zfs create -p -o mountpoint=legacy rpool/local/nix
zfs set compression=lz4 rpool/local/nix
zfs create -p -o mountpoint=legacy rpool/local/nix-store
zfs set compression=lz4 rpool/local/nix-store
zfs create -p -o mountpoint=legacy rpool/local/cache
zfs set compression=lz4 rpool/local/cache
zfs create -p -o mountpoint=legacy rpool/safe/data
zfs set compression=lz4 rpool/safe/data

mount -t zfs rpool/local/root /mnt

mkdir -p /mnt/boot
mount "${diska}3" /mnt/boot

mkdir -p /mnt/nix/
mount -t zfs rpool/local/nix /mnt/nix

mkdir -p /mnt/nix/store
mount -t zfs rpool/local/nix-store /mnt/nix/store

mkdir -p /mnt/cache
mount -t zfs rpool/local/cache /mnt/cache

mkdir -p /mnt/data
mount -t zfs rpool/safe/data /mnt/data
```
