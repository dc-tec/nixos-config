# Forge

`forge` is the dedicated personal engineering server. It hosts public forge
services and supporting infrastructure. It is not a general-purpose homelab or
a platform for customer data.

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
| Public endpoint | `vpn.decort.tech:51820` |
| Server private key | `/var/lib/wireguard/forge.key` |

The VPN DNS record must remain DNS-only in Cloudflare because the standard
proxy does not forward WireGuard. Administrative SSH is available at
`roelc@10.77.0.1`; the provider KVM is the break-glass path.
The public SSH listener also serves Tangled Git traffic, but `AllowUsers`
restricts `roelc` to the WireGuard workstation address and permits only the
Knot's dynamic `git` account from other networks.

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
- the Radicle node identity key; and
- the SSH host keys; and
- the Tangled Knot database and hosted Git repositories.

Nix store paths, cache contents, logs, metrics and reconstructible Radicle
replicas are not included. The Knot is authoritative for repositories assigned
to it, so its state is included even though those repositories are public. New
stateful services must add their authoritative state explicitly. The backend's
1000-object limit is monitored and constrains future expansion.

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

The state job stops the Knot before Restic reads its SQLite database and bare
repositories, then restarts it in the cleanup hook even when the backup fails.
This creates one consistent snapshot at the cost of pausing Git hosting for the
duration of the nightly state backup.

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
- public cache health and signing-key presence;
- Radicle replication health and declared repository policy; and
- Tangled Knot state, listeners, public endpoint and owner identity.

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

## Radicle Node

Forge runs a selective Radicle seed node on public TCP port `8776`. The node
advertises `radicle.decort.tech:8776`; the DNS record remains DNS-only because
the Radicle protocol does not traverse the Cloudflare HTTP proxy. The HTTP
gateway and web explorer are not enabled.

The node uses a dedicated identity rather than the workstation maintainer
identity:

```text
Node ID: z6Mkv2Vt5s46dasz4m2Ht7rA8nnxDnwXp4Q6enhwt2V1RKMZ
Address: z6Mkv2Vt5s46dasz4m2Ht7rA8nnxDnwXp4Q6enhwt2V1RKMZ@radicle.decort.tech:8776
```

The public key is committed in `public-keys.nix`. SecretSpec keeps the
unencrypted private key in the operator's Apple Keychain and provisions it to:

```text
/var/lib/forge-secrets/radicle-node
```

An unencrypted key is used because the node must restart unattended. The file
is root-owned with mode `0400` and is passed to the confined service as a
systemd credential. Provision it over WireGuard with:

```console
secretspec check --profile default --scope forge-radicle \
  --reason "Provision the Forge Radicle node identity"
secretspec run --profile default --scope forge-radicle \
  --reason "Provision the Forge Radicle node identity" -- \
  provision-forge-radicle-key
```

The service is skipped when the key is absent instead of entering a restart
loop. After provisioning a newly deployed host, start the node and apply the
declared repository policy:

```console
ssh roelc@10.77.0.1 sudo systemctl start \
  radicle-node.service \
  forge-radicle-seed.service \
  forge-radicle-metrics.service
```

The default seeding policy is `block`. `forge-radicle-seed.service` grants a
`followed` policy only to the public repository identifiers declared in the
Radicle module. It currently seeds `nixos-config`; removing a repository from
that list does not delete its existing replica automatically.

The service has an explicit memory and task budget so public replication cannot
consume the engineering server without bound. Monitoring verifies the node's
administrative interface, each declared repository identity, and its expected
`followed` policy in addition to process and listener availability.

Inspect the node and its policies with:

```console
ssh roelc@10.77.0.1 sudo rad-system node status
ssh roelc@10.77.0.1 sudo rad-system node config --addresses
ssh roelc@10.77.0.1 sudo rad-system seed
ssh roelc@10.77.0.1 sudo journalctl -u radicle-node.service
```

From another Radicle node, verify the public path with:

```console
rad node connect \
  z6Mkv2Vt5s46dasz4m2Ht7rA8nnxDnwXp4Q6enhwt2V1RKMZ@radicle.decort.tech:8776
rad sync status
```

The encrypted Forge backup includes the node identity key. Replicated public
repository data under `/var/lib/radicle` is reconstructible and deliberately
excluded. The configured repository list restores the seeding policy after a
new node starts. A restore must reproduce the same Node ID before the recovered
node is advertised.

To roll back the service, stop the node and remove the module from the Forge
composition. Preserve the identity key until the old Node ID and address have
been retired deliberately.

## Tangled Knot

Forge runs a single-operator Tangled Knot at `knot.decort.tech`. The Knot hosts
Git data while the public `tangled.org` AppView and the operator's existing AT
Protocol identity provide discovery and collaboration records. Forge does not
run an AppView, PDS, PLC directory, search service or Spindle in this slice.

The deployment pins Tangled `v1.16.1-alpha` and uses its upstream NixOS module.
Its network boundaries are:

| Surface | Exposure | Purpose |
| --- | --- | --- |
| HTTPS `443` | Public through Nginx and ACME | Knot HTTP, XRPC and event endpoints |
| SSH `22` as `git` | Public | Git clone, fetch and push |
| SSH `22` as `roelc` | WireGuard source `10.77.0.2` only | Host administration |
| HTTP `127.0.0.1:5555` | Loopback | Nginx upstream |
| HTTP `127.0.0.1:5444` | Loopback | Knot internal API and SSH key lookup |

The Cloudflare record must remain DNS-only. TLS terminates on Forge and Git SSH
does not traverse the Cloudflare proxy. Knot ownership is declared as:

```text
did:plc:wrl7x5yocird6ep6472fkm3a
```

Secure Mode is enabled. Git subprocesses are confined to their repository with
Landlock and run under owner-specific virtual UIDs. Forge's kernel is newer
than the upstream Linux 5.19 requirement for push-safe Landlock isolation. The
service receives only the setuid, setgid and chown capabilities required by
that mode and has explicit memory, task and systemd hardening limits. The
upstream release emits debug-level logs unconditionally; a per-service burst
limit prevents automated public scans from overwhelming journald.

Authoritative state lives under `/var/lib/tangled-knot`:

- `knotserver.db` contains the Knot database and access model;
- `repos/` contains the hosted bare repositories; and
- the system OpenSSH host key provides continuity for Git clients.

This state is backed up consistently by the daily Forge state job. Restore the
directory and SSH host keys before announcing a replacement Knot. The Knot has
no additional bootstrap secret in this version; its owner and public service
configuration are declarative.

After the service passes its local and public checks, register
`knot.decort.tech` from the Knot settings page on `tangled.org`. Registration
publishes the Knot record through the operator's PDS and verifies the public
owner endpoint. Do not register an incomplete or temporary deployment.

Inspect the service with:

```console
ssh roelc@10.77.0.1 systemctl status knot.service
ssh roelc@10.77.0.1 sudo journalctl -u knot.service
curl -fsS https://knot.decort.tech/
curl -fsS https://knot.decort.tech/xrpc/sh.tangled.owner | jq
ssh -T git@knot.decort.tech
```

Monitoring checks both loopback listeners, the public TLS endpoint, the owner
DID and the on-disk database. The dashboard also reports repository count and
state size. To roll back, remove the Knot module and Nginx virtual host, then
switch the Forge configuration. Preserve `/var/lib/tangled-knot` and the SSH
host keys until the Knot registration has been retired or moved deliberately.

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

## Planned Services

Stateful applications are added as independent, reversible slices:

1. OpenBao with identity integration; and
2. an optional private Attic evaluation, separate from the native cache.

Each service must define its network exposure, state ownership, backup and
restore procedure, monitoring, acceptance checks and rollback path.
