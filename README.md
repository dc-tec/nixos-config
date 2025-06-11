<h1 align="center">Welcome to my NixOS Configuration Repository</h1>

<p align="center">
    <img src="https://img.shields.io/badge/Version-69.420.0-orange" alt="Version Deez-Nutzzzz">
    <img src="https://img.shields.io/badge/NixOS-5277C3?style=for-the-badge&logo=nixos&logoColor=white" alt="Version Yo Mama">
</p>

<p align="center">
    This is my NixOS configuration, designed to create fully reproducible operating systems using the Nix package manager, home-manager, and flakes.
    The primary focus is on cloud automation and development workflows, providing a streamlined and declarative configuration tailored to my needs.
</p>

#### NixOS

![desktop](./docs/images/desktop.png)

#### MacOS

![macbook](./docs/images/macbook.png)

## Highlights

- ZFS with impermanence (blank snapshot at boot) - configurable per machine
- SOPS Nix for secret management
- Custom [NixVim](https://github.com/dc-tec/nixvim) flake
- Hyprland as tiling window manager
- Catppuccin themed across all systems
- WSL2 support with persistence disabled
- Darwin configuration with shared modules
- Flexible architecture supporting both persistent and ephemeral systems

## Architecture

The repository follows a modular architecture with clear separation between different system types and shared functionality:

### Machines

Contains per-device hardware configuration and host-specific settings:

- **chad** - Desktop workstation with ZFS + impermanence, virtualization
- **legion** - Laptop with ZFS + impermanence, mobile setup
- **ghost** - WSL2 instance with persistence disabled
- **darwin** - macOS configuration using nix-darwin

### Modules

#### Shared

Common configuration and utilities used across all systems:

- **config/** - Base system configuration (OS detection, persistence options, theming)
- **development/** - Development tools and environments
- **home-manager/** - Home Manager integration with Catppuccin theming
- **utils/** - Common utilities (SSH, ZSH, direnv, etc.)

#### NixOS

Linux-specific modules:

- **connectivity/** - Network and wireless configuration
- **desktop/** - Desktop environment components (Hyprland, applications, themes)
- **storage/** - ZFS and filesystem management
- **virtualization/** - Docker and KVM/QEMU setup

#### Darwin

macOS-specific modules:

- **desktop/** - macOS desktop customization
- **homebrew/** - Homebrew package management integration

### Additional Components

- **lib/** - Custom library functions and utilities
- **overlays/** - Nixpkgs overlays and package modifications
- **pkgs/** - Custom packages and derivations
- **secrets/** - SOPS-encrypted secrets management

## Key Features

### Flexible Persistence Model

The configuration supports both persistent and ephemeral systems:

- **NixOS machines** (chad, legion): ZFS with impermanence enabled by default
- **WSL2** (ghost): Persistence disabled for compatibility
- **Darwin** (darwin): Standard macOS filesystem behavior
- Configurable per-machine via `dc-tec.persistence.enable`

### ZFS Configuration

ZFS is used on compatible systems with:

- Encrypted datasets with passphrase unlock
- Automatic snapshots and rollback to blank state on boot
- Optimized compression settings
- Separate pools for ephemeral and persistent data

### Cross-Platform Theming

Catppuccin theme consistently applied across:

- Terminal applications
- Desktop environments
- Development tools
- Both NixOS and Darwin systems

### Development Environment

Comprehensive development setup including:

- Docker and virtualization support
- Custom NixVim configuration
- Shell environment with ZSH and modern CLI tools
- Direnv for project-specific environments

## System Configurations

### NixOS with ZFS + Impermanence (chad, legion)

Full desktop systems with ephemeral root filesystem, automated backups, and development tools.

### WSL2 (ghost)

Lightweight development environment for Windows hosts with persistence disabled for compatibility.

### Darwin (darwin)

Native macOS configuration using nix-darwin with homebrew integration and shared module architecture.

## Quick Start

Build and switch to a configuration:

```bash
# NixOS
sudo nixos-rebuild switch --flake .#<hostname>

# Darwin
darwin-rebuild switch --flake .#darwin

# Check available configurations
nix flake show
```

## References

- [Erase Your Darlings](https://grahamc.com/blog/erase-your-darlings/)
- [NixOS Impermanence](https://github.com/nix-community/impermanence)
- [nix-darwin](https://github.com/LnL7/nix-darwin)

#### Wallpapers

- [Orxngc](https://github.com/orxngc/walls-catppuccin-mocha)

#### Disclaimer

This repository serves as a reference implementation but is not intended to run as-is on other systems. Feel free to use components and concepts for your own configuration. For questions or issues, please create a GitHub issue.
