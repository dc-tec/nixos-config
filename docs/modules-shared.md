# Shared Modules

This directory contains modules that are shared between NixOS and Darwin systems. These modules provide common functionality, configuration options, and utilities that work across both platforms.

## Structure

The shared module is organized into several subdirectories:

- **config/** - Core configuration options for operating system detection, user settings, and system-wide options
- **development/** - Development tools and configurations shared across platforms
- **home-manager/** - Home Manager configuration and integration
- **utils/** - Command-line utilities and tools
- **system.nix** - System-wide configuration including Nix settings, fonts, and environment variables

## Key Features

### Cross-Platform Compatibility

The shared modules automatically detect the operating system (Linux/Darwin) and adjust configurations accordingly through the `dc-tec.isLinux` and `dc-tec.isDarwin` options.

### User Configuration

Centralized user configuration including:

- User identity (name, email, GPG keys)
- Home directory management
- Shell and editor preferences
- Platform-specific user settings

### System Configuration

Common system settings that apply to both NixOS and Darwin:

- Nix configuration with flakes and experimental features
- Font management
- Time zone settings
- Environment variables

### Development Environment

Shared development tools and configurations that work consistently across platforms.

### Utility Applications

A curated set of command-line utilities and applications configured with sensible defaults.

## Usage

The shared module is automatically imported by both NixOS and Darwin configurations through the `sharedModules` list in the flake.nix file.

Configuration options are available under the `dc-tec` namespace and can be customized in machine-specific configurations.
