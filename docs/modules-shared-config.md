# Configuration Modules

This directory contains the core configuration modules that define system-wide options and settings shared between NixOS and Darwin.

## Modules

### os.nix

Defines operating system detection and system-wide configuration options.

**Key Options:**

- `dc-tec.isLinux` - Read-only boolean indicating if the system is Linux
- `dc-tec.isDarwin` - Read-only boolean indicating if the system is Darwin/macOS
- `dc-tec.font` - Default system font (automatically set based on platform)
- `dc-tec.colorScheme.flavor` - Catppuccin color scheme flavor (default: "macchiato")
- `dc-tec.colorScheme.accent` - Catppuccin accent color (default: "peach")
- `dc-tec.stateVersion` - System state version for compatibility
- `dc-tec.timeZone` - System timezone (default: "Europe/Amsterdam")
- `dc-tec.persistence.*` - Impermanence/persistence configuration options

**Features:**

- Automatic platform detection
- Font selection based on operating system
- Persistence configuration for NixOS systems
- Color scheme management

### user.nix

Manages user account configuration and settings.

**Key Options:**

- `dc-tec.user.name` - Primary username (default: "roelc")
- `dc-tec.user.fullName` - User's full name (default: "Roel de Cort")
- `dc-tec.user.email` - Primary email address
- `dc-tec.user.workEmail` - Work email address
- `dc-tec.user.gpgKey` - User's GPG key ID
- `dc-tec.user.homeDirectory` - Home directory path (auto-configured)
- `dc-tec.user.shell` - Default shell (default: "zsh")
- `dc-tec.user.editor` - Default editor (default: "nvim")

**Features:**

- Cross-platform user account creation
- Automatic home directory detection
- Platform-specific user configuration
- Group management
- Password file integration with SOPS

## Platform Compatibility

The configuration modules handle differences between NixOS and Darwin automatically:

- **Linux**: Creates normal user accounts with groups, password files, and system journal access
- **Darwin**: Uses Darwin-specific user management
- **Shared**: Common settings like home directory, shell, and editor work on both platforms
