# Chad Machine Configuration

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
