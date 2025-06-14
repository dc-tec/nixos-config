# Storage Management

This module provides advanced storage management for NixOS systems, with a focus on ZFS and impermanence configurations.

## Features

- **ZFS Integration** - Full ZFS support with encryption and compression
- **Impermanence** - Ephemeral root filesystem with selective persistence
- **Automatic Snapshots** - Rollback to clean state on boot
- **Flexible Persistence** - Configurable data and cache persistence
- **Security** - Encrypted datasets with passphrase protection

## ZFS Configuration

### Basic ZFS Setup

```nix
{
  dc-tec.core.zfs = {
    enable = true;
    encrypted = true;
    rootDataset = "rpool/local/root";
  };
}
```

### Persistence Configuration

The module integrates with the impermanence system to provide selective persistence:

```nix
{
  dc-tec.core.zfs = {
    # System directories to persist
    systemDataLinks = [
      "/etc/ssh"
      "/var/lib/bluetooth"
      "/var/lib/systemd/coredump"
    ];

    # System cache directories
    systemCacheLinks = [
      "/var/cache/nix"
      "/var/log"
    ];

    # User data directories to persist
    homeDataLinks = [
      ".ssh"
      ".gnupg"
      "Documents"
      "projects"
    ];

    # User cache directories
    homeCacheLinks = [
      ".cache"
      ".local/share/direnv"
    ];

    # Ensure directories exist on boot
    ensureSystemExists = [
      "/data/etc/ssh"
    ];

    ensureHomeExists = [
      ".ssh"
      ".gnupg"
    ];
  };
}
```

## Impermanence Model

This module implements an impermanence model where:

1. **Root filesystem is ephemeral** - Rolled back to blank snapshot on boot
2. **Selective persistence** - Only specified directories survive reboots
3. **Separate data/cache pools** - Different retention policies for data vs cache
4. **Automatic cleanup** - Temporary files are automatically removed

### Dataset Structure

```
rpool/
├── local/           # Ephemeral data
│   ├── root         # Root filesystem (rolled back on boot)
│   ├── nix          # Nix store
│   └── cache        # System cache
└── safe/            # Persistent data
    └── data         # User and system data
```

## Security Features

### Encryption

- **Dataset encryption** - AES-256-GCM encryption
- **Passphrase protection** - Prompted during boot
- **Key management** - Secure key derivation

### Access Control

- **User isolation** - Proper ownership and permissions
- **System separation** - Separate datasets for system and user data

## Maintenance Tools

The module provides several maintenance utilities:

### ZFS Diff Tool

```bash
# Show changes since last blank snapshot
zfsdiff
```

This tool helps identify what files have been created or modified since the last clean boot, useful for deciding what to persist.

### Snapshot Management

- **Automatic snapshots** - Created before rollback
- **Manual snapshots** - For backup purposes
- **Rollback capability** - Return to clean state

## Platform Integration

### NixOS Integration

- **Boot integration** - ZFS modules loaded during boot
- **Service integration** - ZFS services (scrub, trim) enabled
- **Hardware support** - Proper device node configuration

### Home Manager Integration

- **User persistence** - Home directory persistence configuration
- **Shell integration** - ZFS-aware shell aliases and functions

## Troubleshooting

### Common Issues

1. **Boot hangs waiting for passphrase**

   - Ensure encrypted datasets are properly configured
   - Check keyboard layout during boot

2. **Persistence not working**

   - Verify dataset mount points
   - Check directory permissions
   - Ensure impermanence module is loaded

3. **Performance issues**
   - Adjust compression settings
   - Monitor ARC usage
   - Consider dataset recordsize tuning

### Recovery

If the system becomes unbootable:

1. Boot from NixOS installer
2. Import ZFS pool: `zpool import -f rpool`
3. Mount datasets manually
4. Chroot and rebuild configuration

## Best Practices

1. **Regular scrubs** - Enabled automatically for data integrity
2. **Monitor disk usage** - ZFS compression helps but monitor growth
3. **Backup strategy** - Consider ZFS send/receive for backups
4. **Test rollbacks** - Regularly test the rollback mechanism
5. **Document persistence** - Keep track of what needs to persist

## Examples

### Desktop Workstation

```nix
{
  dc-tec.core.zfs = {
    enable = true;
    encrypted = true;
    rootDataset = "rpool/local/root";

    systemDataLinks = [
      "/etc/ssh"
      "/var/lib/bluetooth"
      "/var/lib/cups"
    ];

    homeDataLinks = [
      ".ssh"
      ".gnupg"
      "Documents"
      "Pictures"
      "projects"
      ".config/git"
    ];

    homeCacheLinks = [
      ".cache"
      ".local/share/Steam"
    ];
  };
}
```

### Development Server

```nix
{
  dc-tec.core.zfs = {
    enable = true;
    encrypted = true;
    rootDataset = "rpool/local/root";

    systemDataLinks = [
      "/etc/ssh"
      "/var/lib/docker"
      "/var/lib/postgresql"
    ];

    homeDataLinks = [
      ".ssh"
      "projects"
      ".config/git"
    ];

    systemCacheLinks = [
      "/var/cache/nix"
      "/var/log"
    ];
  };
}
```
