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
deriving and comparing its public key. The key is also included in the host
backup and restore procedure below.

## Backup Policy

The first backup slice uses Restic through rclone's FTP backend and the 100 GB
Scaleway Dedibackup allocation. It deliberately protects only the host identity
material that cannot be reconstructed from this repository:

- `/var/lib/wireguard/forge.key`; and
- `/var/lib/forge-secrets/nix-cache-private-key`, once provisioned; and
- the SSH host key files under `/etc/ssh`.

Nix store paths, `/cache`, logs, metrics, and public Git repositories remain
outside this initial set. The allocation has a 1000-file limit, so repository
growth must be monitored before broader service state is added.

SecretSpec stores the Restic repository password in the workstation's Apple
Keychain through its `keyring` provider. SecretSpec is an operator-side
provisioning tool; it is not a runtime or boot dependency of `forge`. Create or
resolve the generated password without printing it, then transfer it over the
WireGuard-only SSH path:

```console
secretspec check --profile default --scope forge-backup \
  --reason "Provision the forge backup repository password"
secretspec run --profile default --scope forge-backup \
  --reason "Provision the forge backup repository password" -- \
  ./scripts/provision-forge-backup-secret
```

The script writes only `/var/lib/forge-secrets/restic-password` on the host. It
is owned by root with mode `0400`. Dedibackup autologin is tied to the server's
provider network and uses the non-secret `auto` account with an empty password;
the Scaleway account password is not part of the configuration.

The repository is already initialized; the service does not initialize it
automatically. A persistent timer creates a snapshot daily at 03:00 local time
with up to 30 minutes of randomized delay. A separate persistent maintenance
timer runs on Sunday at 05:30 local time, also with up to 30 minutes of
randomized delay. It applies the following retention policy and then reads and
verifies all repository data:

- 14 daily snapshots;
- 8 weekly snapshots; and
- 6 monthly snapshots.

Backup and maintenance are separate jobs because adding prune and check options
to the backup job would run them after every snapshot. The weekly maintenance
job instead performs `unlock`, `forget --prune`, and `check --read-data` in that
order.

The initial repository, scheduled services, retention run, full data check, and
isolated restore were verified on 2026-07-29. The restore contained the five
expected files and produced the same WireGuard public identity and the same
Ed25519 and RSA SSH fingerprints as the live host. The repository contained
seven backend objects after this acceptance test, well below the provider's
1000-file limit. The host had no failed systemd units.

Only initialize the repository again when reconstructing a new, empty backend.
Inspect the schedules and recent executions with:

```console
ssh roelc@10.77.0.1 systemctl list-timers --all \
  restic-backups-forge-state.timer \
  restic-backups-forge-maintenance.timer
ssh roelc@10.77.0.1 sudo journalctl \
  -u restic-backups-forge-state.service \
  -u restic-backups-forge-maintenance.service
```

Run either job manually and inspect the repository with:

```console
ssh roelc@10.77.0.1 sudo systemctl start restic-backups-forge-state.service
ssh roelc@10.77.0.1 sudo systemctl start \
  restic-backups-forge-maintenance.service
ssh roelc@10.77.0.1 sudo restic-forge-state snapshots
ssh roelc@10.77.0.1 sudo restic-forge-state check --read-data
```

For subsequent restore tests, restore the latest snapshot into a temporary
directory, derive the restored WireGuard public key, and compare the restored
SSH host-key fingerprints. A successful backup alone is not sufficient restore
evidence.

## Monitoring and Local Alerting

Prometheus retains 30 days of host metrics on the mirrored root filesystem and
listens only on `127.0.0.1:9090`. Its node and SMART exporters also listen only
on loopback. The node exporter includes the systemd and textfile collectors;
the SMART exporter discovers and monitors all three local SSDs.

Grafana listens on `10.77.0.1:3000` and the firewall permits that port only on
`wg0`. It provides an anonymous read-only view to WireGuard peers, disables the
login form and initial administrator account, and provisions its Prometheus
datasource and `Forge Overview` dashboard from this repository. Grafana creates
its database encryption key locally in `/var/lib/grafana/secret-key` before its
first start. The key and Grafana database are disposable while all dashboards
and datasources remain declarative and contain no credentials. Revisit that
boundary before storing credentials or non-declarative state in Grafana.

Successful backup and maintenance jobs trigger separate metric-writer units.
They atomically publish their last-success timestamps to the node exporter's
textfile directory without changing the result of the backup job. A persistent
inventory timer runs daily at 04:00 with up to 30 minutes of randomized delay
and records the Dedibackup repository object count and inventory timestamp.

Inspect the monitoring foundation with:

```console
open http://10.77.0.1:3000/d/forge-overview/forge-overview
ssh roelc@10.77.0.1 systemctl status \
  prometheus.service \
  prometheus-node-exporter.service \
  prometheus-smartctl-exporter.service \
  grafana.service
ssh roelc@10.77.0.1 systemctl list-timers \
  forge-backup-inventory-metrics.timer
```

The foundation was verified on 2026-07-29 with all three Prometheus targets
healthy, both RAID arrays reporting no degraded members, all three SSDs
reporting healthy SMART status, all four custom backup metrics present, and the
provisioned dashboard reachable through WireGuard. Grafana was not reachable
on the public interface.

Prometheus evaluates declarative alerts for exporter and service availability,
RAID and SMART health, root and cache capacity, root inode exhaustion, OOM
kills, backup and inventory freshness, and the Dedibackup object ceiling. CPU
load is intentionally not an alert because Nix builds are expected to saturate
the host. Warning and critical capacity expressions do not overlap.

Alertmanager listens only on `127.0.0.1:9093`. Its `local-only` receiver has no
email, webhook, or other outbound integration, so alerts remain inspectable on
the host without leaving it. The Grafana dashboard shows the current firing
alert count, backup ages, and backend object count. Inspect the rule and
Alertmanager state with:

```console
ssh roelc@10.77.0.1 curl -fsS http://127.0.0.1:9090/api/v1/alerts
ssh roelc@10.77.0.1 curl -fsS http://127.0.0.1:9090/api/v1/rules
ssh roelc@10.77.0.1 curl -fsS http://127.0.0.1:9093/api/v2/status
```

Scaleway's independent server-ping notification remains the external check for
whole-host or provider-network loss. Exchange Online delivery to
`roel@decort.tech` will be a later slice, after its connector and authentication
boundary have been selected.

The local alerting path was verified on 2026-07-29: all 15 rules passed syntax
and behavior checks, all four live rule groups reported healthy, Prometheus and
Alertmanager were connected, and no real alerts were pending or firing. A
short-lived acceptance alert was received and expired through the loopback-only
Alertmanager API. Alertmanager was not reachable on the public interface.

## Native Nix Binary Cache

The cache design uses Nix's native local binary-cache store rather than an
Internet-facing Attic write API. `cache.decort.tech` serves the static cache
over HTTPS and permits only `GET` and `HEAD`. There is no HTTP upload endpoint.
The DNS-only Cloudflare record resolves directly to the forge public address so
the host can obtain and renew its ACME certificate through the HTTP challenge.

The cache data lives under `/cache/nix` on the independent cache SSD. Nix uses
zstd compression and signs each published store path with the
`cache.decort.tech-1` key. Shared workstation configuration trusts the public
half committed at `keys/forge-cache.pub`; the private half is stored in the
operator's Apple Keychain through SecretSpec and is provisioned only to:

```text
/var/lib/forge-secrets/nix-cache-private-key
```

The private key remains readable only by root. Cache contents are intentionally
excluded from backup because they can be rebuilt. The signing key is included
in the encrypted forge state backup after provisioning.

Provision and verify the signing key over WireGuard before activating the
cache configuration:

```console
secretspec check --profile default --scope forge-cache \
  --reason "Provision the forge binary-cache signing key"
secretspec run --profile default --scope forge-cache \
  --reason "Provision the forge binary-cache signing key" -- \
  ./scripts/provision-forge-cache-key
```

Publishing is a two-stage operation. The workstation first copies an already
realized closure into the forge Nix store over the WireGuard-only SSH path. A
root-only server command then copies and signs that closure into the static
cache. The helper performs both steps without transferring the signing key:

```console
store_path="$(nix build --no-link --print-out-paths .#PACKAGE)"
./scripts/publish-forge-cache "$store_path"
```

For deliberate Darwin milestones, the `nhdsp` Zsh alias runs the
`nh-darwin-switch-publish` wrapper. It asks `nh` to retain the activated system
as a temporary output link and publishes that exact closure only after the
switch succeeds. The existing `nhds` alias remains the switch-only path for
routine, experimental, and offline rebuilds.

The Mac, Chad, Forge, and the other shared configurations use the cache as an
additional substituter with priority 30. Exact cache hits remain platform
specific: Forge and Chad can share `x86_64-linux` outputs, while the Apple
Silicon workstation primarily reuses `aarch64-darwin` outputs that it has
published previously.

The node exporter records public endpoint health, signing-key presence, cache
path count, logical cache bytes, and metric freshness. Prometheus alerts when
the public endpoint or signing key is unavailable, when metrics become stale,
or when the cache filesystem approaches its capacity limit. Native cache
eviction is deliberately manual in the first slice; the cache must not be
cleared merely because an automated age threshold was reached.

After activation, publish a small closure and verify both its metadata and its
signature from a client:

```console
hello="$(nix build --no-link --print-out-paths nixpkgs#hello)"
./scripts/publish-forge-cache "$hello"
narinfo="$(basename "$hello" | cut -d- -f1)"
curl -fsSI "https://cache.decort.tech/$narinfo.narinfo"
nix path-info --store https://cache.decort.tech "$hello"
nix store verify --no-contents --recursive "$hello"
```

GitHub-hosted jobs continue to read from and publish to Cachix in this slice.
They can be configured to read from the forge cache later, without receiving a
write credential. Giving external runners forge cache publication authority
remains outside this design. Attic may be evaluated separately on WireGuard
with a disposable key and cache namespace.

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

1. external alert delivery through Exchange Online;
2. Radicle and Tangled;
3. OpenBao and identity integration; and
4. a private Attic evaluation, separate from the trusted native cache.
