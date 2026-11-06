# Forge

`forge` is the dedicated personal engineering server. It provides a Nix binary
cache, a development VM, monitoring, and host backups. It does not host customer
data.

## Configuration

Forge uses the stable NixOS package set and is assembled from three layers:

- `modules/nixos/server` provides the reusable server baseline;
- `modules/nixos/server/forge` provides the engineering services; and
- `machines/forge` contains host identity, hardware, storage and networking.

The server does not inherit workstation Home Manager configuration, desktop
theming, impermanence or personal SOPS material. Automatic upgrades are
disabled so package-set changes remain explicit.

The baseline provides:

- key-only SSH for the `roelc` administrator account;
- a locked root account and disabled root SSH login;
- a default-deny firewall;
- administrative SSH only through WireGuard, with forwarding disabled;
- fail2ban, SMART monitoring, SSD trimming and compressed swap; and
- scheduled Nix garbage collection and store optimisation.

The public interface, `enp1s0f0`, uses DHCP. The second network interface is
not configured.

## Storage

The server boots through legacy BIOS and contains three SATA SSDs. Disko
defines:

- a BIOS boot partition on each durable disk, with GRUB installed to both;
- a 1 GiB ext4 `/boot` mdadm RAID1 array;
- an ext4 `/` mdadm RAID1 array using the remaining durable capacity; and
- an independent ext4 `/cache` filesystem on the third SSD.

`/cache` contains reconstructible data and uses `nofail`; losing it must not
prevent the server from booting. The root and boot arrays contain persistent
state and must remain mirrored.

Disko and `nixos-anywhere` are destructive. Before reinstalling, compare the
stable device paths in `machines/forge/disko.nix` with the live
`/dev/disk/by-id` inventory. The configured kernel compatibility assertion must
also remain satisfied when recreating the mdraid arrays.

## Administration Network

WireGuard is the administration boundary:

| Item | Value |
| --- | --- |
| Server address | `10.77.0.1/24` |
| Workstation peer | `10.77.0.2/32` |
| Chad lab host peer | `10.77.0.3/32`, routing `10.79.0.0/22` |
| iPhone peer | `10.77.0.4/32`, restricted to T3 on the workstation |
| Public endpoint | `vpn.decort.tech:51820` |
| Server private key | `/var/lib/wireguard/forge.key` |

The VPN DNS record must remain DNS-only in Cloudflare because the standard
proxy does not forward WireGuard. Administrative SSH is available at
`roelc@10.77.0.1`; the provider KVM is the break-glass path.
The SSH allowlist contains only `roelc@10.77.0.2`. Public Git SSH access is
disabled.

Forge relays workstation-initiated traffic to Chad and its lab guest range.
The `forge-lab-relay` chain accepts only new flows from `10.77.0.2` and their
replies; Chad and lab guests cannot open connections through Forge or reach its
public interface.
Relayed traffic is decrypted and re-encrypted on Forge, so lab administration
protocols must be end-to-end encrypted. See `machine-chad.md` for the lab side.

The iPhone peer can open TCP connections only to `10.77.0.2:3773`. The
`forge-t3-mobile` chain accepts those connections and their TCP replies. It
blocks all other forwarding involving the phone. A separate input rule blocks
the phone from Forge's services, including services allowed for other VPN peers.
See [T3 access from iPhone](t3-iphone-wireguard.md) for the client configuration
and the current HTTP transport boundary.

Inspect WireGuard and derive the server's public key with:

```console
sudo wg show wg0
sudo sh -c 'wg pubkey < /var/lib/wireguard/forge.key'
```

The private key is generated on the host, kept outside the repository and Nix
store, copied to the operator's password manager, and included in the encrypted
host backup.

## Backup and Restore

Restic writes encrypted backups to the 100 GB Scaleway Dedibackup allocation
through rclone's FTP backend. The initial backup set contains state that cannot
be reconstructed from this repository:

- the WireGuard private key;
- the Nix cache signing key;
- the SSH host keys; and
- retained Tangled repository data and the retired Radicle identity key, when
  those files are present.

Nix store paths, cache contents, logs, metrics, and reconstructible Radicle
replicas are excluded. Retained Tangled data remains in backups until its
repositories have been migrated or deliberately deleted. New stateful services
must add their authoritative state. The backend's 1000-object limit is monitored
and constrains future expansion.

SecretSpec resolves the Restic password from the operator's Apple Keychain and
provisions it over WireGuard. It is not a runtime dependency of Forge:

```console
secretspec check --profile default --scope forge-backup \
  --reason "Provision the forge backup repository password"
secretspec run --profile default --scope forge-backup \
  --reason "Provision the forge backup repository password" -- \
  provision-forge-backup-secret
```

The resulting `/var/lib/forge-secrets/restic-password` file is owned by root
with mode `0400`. The backup repository is initialized separately and is never
initialized automatically by the service.

The schedule and retention policy are:

- daily snapshot at 03:00, with up to 30 minutes of randomized delay;
- weekly maintenance on Sunday at 05:30;
- 14 daily, 8 weekly and 6 monthly snapshots; and
- weekly prune followed by a full repository data check.

Inspect or run the jobs with:

```console
ssh roelc@10.77.0.1 systemctl list-timers --all \
  restic-backups-forge-state.timer \
  restic-backups-forge-maintenance.timer
ssh roelc@10.77.0.1 sudo journalctl \
  -u restic-backups-forge-state.service \
  -u restic-backups-forge-maintenance.service
ssh roelc@10.77.0.1 sudo systemctl start \
  restic-backups-forge-state.service
ssh roelc@10.77.0.1 sudo restic-forge-state snapshots
ssh roelc@10.77.0.1 sudo restic-forge-state check --read-data
```

A restore test must compare the restored WireGuard identity and SSH host-key
fingerprints with the live host. A successful snapshot alone is not sufficient
restore evidence.

## Monitoring and Alerting

Prometheus retains 30 days of host metrics on the mirrored root filesystem.
Prometheus, Alertmanager, the node exporter and the SMART exporter listen only
on loopback. Grafana is available to WireGuard peers at:

```text
http://10.77.0.1:3000/d/forge-overview/forge-overview
```

Grafana provides an anonymous read-only view on the administration network.
Its datasource and dashboard are declarative and contain no credentials. Its
local database and encryption key remain disposable while that boundary holds.

The alert rules cover:

- exporter and systemd service availability;
- RAID and SMART health;
- root and cache capacity;
- inode exhaustion and OOM kills;
- backup and inventory freshness;
- the Dedibackup object limit; and
- public cache health and signing-key presence.

CPU saturation is intentionally not an alert because Nix builds are expected
to use the host fully. Warning and critical capacity thresholds do not overlap.
The rule suite is validated with Prometheus's `promtool` in CI.

Alertmanager uses a local receiver and has clustering disabled. External alert
delivery remains deferred until its authentication and trust boundary is
settled. Scaleway's independent server-ping notification covers whole-host and
provider-network loss.

Inspect the monitoring stack with:

```console
ssh roelc@10.77.0.1 systemctl status \
  prometheus.service \
  prometheus-node-exporter.service \
  prometheus-smartctl-exporter.service \
  alertmanager.service \
  grafana.service
ssh roelc@10.77.0.1 curl -fsS http://127.0.0.1:9090/api/v1/alerts
ssh roelc@10.77.0.1 curl -fsS http://127.0.0.1:9090/api/v1/rules
ssh roelc@10.77.0.1 curl -fsS http://127.0.0.1:9093/api/v2/status
```

## Native Nix Cache

`cache.decort.tech` exposes a signed native Nix binary cache over HTTPS. The
endpoint permits only `GET` and `HEAD`; it has no HTTP upload API. Its
Cloudflare record remains DNS-only so the host can terminate TLS and obtain its
ACME certificate.

Cache data lives under `/cache/nix` and is deliberately excluded from backup.
The public signing key is committed in `public-keys.nix`. SecretSpec keeps
the private key in the operator's Apple Keychain and provisions it only to:

```text
/var/lib/forge-secrets/nix-cache-private-key
```

Provision the key over WireGuard with:

```console
secretspec check --profile default --scope forge-cache \
  --reason "Provision the forge binary-cache signing key"
secretspec run --profile default --scope forge-cache \
  --reason "Provision the forge binary-cache signing key" -- \
  provision-forge-cache-key
```

`publish-forge-cache` copies an already realized closure to Forge over SSH and
invokes the root-only signing command on the server:

```console
store_path="$(nix build --no-link --print-out-paths .#PACKAGE)"
publish-forge-cache "$store_path"
```

The `nhdsp` Zsh alias switches the Darwin configuration and publishes the
activated closure. The existing `nhds` alias remains the switch-only path.
Clients use the Forge cache as an additional substituter; cache hits remain
platform-specific.

Verify a published closure from a client with:

```console
hello="$(nix build --no-link --print-out-paths nixpkgs#hello)"
publish-forge-cache "$hello"
narinfo="$(basename "$hello" | cut -d- -f1)"
curl -fsSI "https://cache.decort.tech/$narinfo.narinfo"
nix path-info --store https://cache.decort.tech "$hello"
nix store verify --no-contents --recursive "$hello"
```

GitHub Actions continues to use Cachix. External runners do not receive Forge
publication authority. Cache eviction remains an explicit operator action.

## Retired Git services

Radicle and Tangled are removed from the configuration. Applying this
configuration stops their services, removes their service accounts and
monitoring, closes public Radicle TCP port `8776`, and removes the
`knot.decort.tech` Nginx virtual host and its ACME certificate definition.

The configuration preserves existing data:

- `/var/lib/tangled-knot` contains the Knot database and hosted repositories;
- `/var/lib/radicle` contains replicated Radicle repositories; and
- `/var/lib/forge-secrets/radicle-node` contains the retired node identity.

Restic continues to include retained Knot data and the Radicle identity key
when present. Its hooks no longer restart the retired Knot service. Delete
these files only after deciding how to retain or migrate the repositories.

After activation, retire or move the external Tangled registration and the
`knot.decort.tech` and `radicle.decort.tech` DNS records. This configuration does
not manage those external records.

## Build and Deployment

Evaluate the Forge system and Disko derivations from any supported client:

```console
nix eval --raw .#nixosConfigurations.forge.config.system.build.toplevel.drvPath
nix eval --raw .#nixosConfigurations.forge.config.system.build.diskoScript.drvPath
```

The Apple Silicon workstation delegates the x86-64 build to Forge. Use `test`
before making a generation persistent:

```console
nix run nixpkgs#nixos-rebuild -- test \
  --flake .#forge \
  --build-host roelc@10.77.0.1 \
  --target-host roelc@10.77.0.1 \
  --elevate sudo \
  --use-substitutes \
  --print-build-logs
```

After the acceptance checks pass, replace `test` with `switch`. CI separately
builds the Forge system, Disko script and Prometheus rule suite.

For disaster recovery, review the live disk identities and backup material
before invoking `nixos-anywhere`:

```console
nix run .#nixos-anywhere -- \
  --flake .#forge \
  --build-on-remote \
  --target-host roelc@FORGE_ADDRESS
```

## Remote Development

Forge can host the separately encrypted `forge-dev` NixOS virtual machine.
Its storage boundary, bootstrap sequence, cmux SSH entry and initial
SecretSpec/OpenBao Operator pilot are documented in
[`machine-forge-dev.md`](./machine-forge-dev.md).

## Planned Services

Stateful applications are added as independent, reversible slices:

1. OpenBao with identity integration; and
2. an optional private Attic evaluation, separate from the native cache.

Each service must define its network exposure, state ownership, backup and
restore procedure, monitoring, acceptance checks and rollback path.
