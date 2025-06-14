<h1 align="center">deCort.tech – Nix & Darwin System Configuration</h1>

<p align="center">
    <img src="https://img.shields.io/badge/Built%20with-Nix-blue?logo=nixos" alt="Built with Nix">
    <img src="https://img.shields.io/badge/Flake-ready-green" alt="Nix flake ready">
</p>

<p align="center">
    This flake is the single source of truth for <em>all</em> of my machines – from a beefy desktop to a MacBook (and even a WSL2 shell on Windows).
    With Nix, Home Manager and a handful of extras I can go from a blank disk to a fully-configured, themed and encrypted system in one command.
</p>

#### NixOS

![desktop](./docs/images/desktop.png)

#### MacOS

![macbook](./docs/images/macbook.png)

## Highlights

This flake bundles everything I rely on day-to-day: encrypted ZFS roots with impermanence, secret management through SOPS-age, a custom NixVim setup and a Hyprland-powered desktop – all wrapped in Catppuccin colours. It runs the same on NixOS, macOS (via nix-darwin) and even inside WSL2, providing a flexible foundation whether the machine is fully persistent or stateless.

## Flake Overview

This repository is a Nix _flake_, a self-contained unit that bundles all the dependencies and code needed to build the systems it describes. This includes not just packages from `nixpkgs` (both `unstable` and `25.05` channels) but also essential community flakes like `home-manager` for user-level configuration, `impermanence` for ephemeral systems, and `sops-nix` for secure secret management.

The flake also pulls in specialized inputs for hardware and platform support, such as `nix-darwin` and `nix-homebrew` for macOS, `nixos-wsl` for Windows Subsystem for Linux, and specific `hyprland` components for the Wayland desktop. For a complete list of dependencies, see the [`flake.nix`](./flake.nix) file. You can inspect the flake's outputs by running:

```bash
nix flake show
```

## Architecture

The configuration is structured into a three-tiered modular architecture that cleanly separates hardware-specific, OS-specific, and shared concerns. This design makes it easy to reuse code, override settings for a particular machine, and understand the flow of the build.

### Machines

At the top level, the `machines/` directory defines the individual hosts. Each machine has a dedicated file (e.g., `machines/chad/default.nix`) that specifies its hardware configuration, network settings, and which modules to import. This is where you would define things like disk layouts, graphics drivers, and other host-specific parameters.

The flake includes four reference machines:

- **chad**: A powerful desktop workstation running NixOS with ZFS, impermanence, and virtualization enabled.
- **legion**: A NixOS laptop with a similar ZFS and impermanence setup, but tailored for a mobile environment.
- **ghost**: A minimal WSL2 instance on Windows, configured to be stateless.
- **darwin**: A macOS environment managed with `nix-darwin`.

### Modules

The core logic is organized in the `modules/` directory, which is split into three categories:

- **Shared Modules** (`modules/shared`): This is the foundation for all systems, regardless of the operating system. It includes common configurations for `home-manager`, development tools (`development/`), base system settings (`config/`), and essential utilities like ZSH, Git, and SSH (`utils/`). These modules ensure a consistent user experience across every machine.

- **NixOS Modules** (`modules/nixos`): These modules are specific to Linux hosts. They handle system-level concerns like network connectivity (`connectivity/`), the desktop environment (Hyprland, applications, theming in `desktop/`), storage with ZFS (`storage/`), and virtualization with Docker and KVM (`virtualization/`).

- **Darwin Modules** (`modules/darwin`): These modules target macOS. They configure macOS-specific desktop customizations (`desktop/`) and manage packages through Homebrew (`homebrew/`), integrating them cleanly into the Nix environment.

### Additional Components

- **lib/**: A collection of custom helper functions and utilities that are used throughout the flake.
- **overlays/**: Overlays are used to modify or extend the `nixpkgs` package set with custom packages or versions.
- **pkgs/**: Custom packages and derivations that are not available in other sources.
- **secrets/**: Contains secret files encrypted with SOPS, which are securely decrypted at build time.

## System Configurations

The flake produces several distinct system configurations, each tailored to a specific use case.

### NixOS with ZFS + Impermanence (chad, legion)

These are full-featured desktop and laptop configurations that boot from an encrypted ZFS filesystem. By default, they use an ephemeral root, meaning the system starts from a clean snapshot on every boot. Persistent data is stored on a separate ZFS pool, ensuring that user data is preserved while the system itself remains pristine. This setup is ideal for development and daily use, providing a reproducible and stable environment.

### WSL2 (ghost)

This configuration provides a lightweight, NixOS-based development environment for use with Windows Subsystem for Linux.

### Darwin (darwin)

For macOS, this configuration uses `nix-darwin` to manage the system declaratively. It integrates with Homebrew for packages that are not available in `nixpkgs` and shares the same `home-manager` configuration as the NixOS hosts, ensuring a consistent development environment across platforms.

## Documentation

This repository is designed to be self-documenting. The module system itself serves as the primary source of truth, and detailed comments throughout the code explain the purpose of each option.

In addition, this flake uses `nix-doc` to generate comprehensive HTML documentation from the module options and Markdown files in the `docs/` directory. This includes a full reference of all available configuration options, setup guides, and a deeper overview of the architecture.

To build and view the documentation locally, run the following commands:

```bash
# Build the documentation
nix build .#docs
```

The documentation is also automatically built and deployed to GitHub Pages on every push to the `main` branch.

## Quick Start

Build and switch to a configuration:

```bash
# Using nh to build and switch to a configuration
# NixOS
nh os switch --hostname <hostname>

# Darwin
nh darwin switch --hostname <hostname>
```

or use the following commands:

```bash
# NixOS
nixos-rebuild switch --flake .#<hostname>

# Darwin
darwin-rebuild switch --flake .#<hostname>
```

Check available configurations:

```bash
nix flake show
```

## References

- [Erase Your Darlings](https://grahamc.com/blog/erase-your-darlings/)
- [NixOS Impermanence](https://github.com/nix-community/impermanence)
- [nix-darwin](https://github.com/LnL7/nix-darwin)

#### Wallpapers

- [Orxngc](https://github.com/orxngc/walls-catppuccin-mocha)

#### Disclaimer

I share this repo as inspiration – feel free to copy snippets or raise an issue if something piques your interest. Just keep in mind that some pieces are tailored to my hardware and workflow, so you'll likely need to adapt things for your own setup.
