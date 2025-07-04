# deCort.tech – NixOS Configuration Documentation

Welcome to the documentation for deCort.tech's NixOS and Darwin system configurations.

## Machine Configurations

- **[Chad Machine](machine-chad.html)** - Development workstation configuration
- **[Legion Machine](machine-legion.html)** - Laptop system configuration
- **[Ghost Machine](machine-ghost.html)** - WSL2 system configuration
- **[Darwin Machine](machine-darwin.html)** - macOS system configuration

## Module Documentation

### Shared Modules

- **[Shared Modules Overview](modules-shared.html)** - Common configuration across all systems
- **[Development Setup](modules-shared-development.html)** - Programming tools and environments
- **[Configuration Management](modules-shared-config.html)** - System configuration utilities
- **[Utilities](modules-shared-utils.html)** - Helpful system utilities

### NixOS-Specific Modules

- **[Storage Configuration](modules-nixos-storage.html)** - Disk and filesystem management

### Darwin-Specific Modules

- **[Darwin Overview](modules-darwin.html)** - macOS-specific configurations
- **[Desktop Environment](modules-darwin-desktop.html)** - macOS desktop setup and customization
- **[SHKD Key Bindings](modules-darwin-shkd.html)** - Keyboard shortcuts and window management

## System Management

- **[Adding New Hosts](add-new-host.html)** - Guide for setting up new machines
- **[SOPS Secrets Management](sops.html)** - Secure secrets management with SOPS and age encryption
- **[Maintenance](maintenance.html)** - System maintenance procedures
- **[Overlays](overlays.html)** - Package overlays and stable package usage
- **[Troubleshooting](troubleshooting.html)** - Common issues and solutions

## Configuration Options

For detailed configuration options available in these modules, see the [Module Options](options.html) page.

---

_This documentation is generated using [NDG (Not a Docs Generator)](https://github.com/feel-co/ndg) and is automatically updated when the system configurations change._
