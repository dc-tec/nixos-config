# Plan for a More Homogeneous NixOS Configuration

The main goal is to unify the configurations for different environments (NixOS, Darwin, WSL) so they share as much code as possible. This will reduce duplication and make the setup easier to manage and extend.

### 1. Unify Module Loading in `flake.nix`

The `flake.nix` currently has separate logic for NixOS, WSL, and Darwin. This will be simplified.

**Current Situation:**
`sharedModules`, `wslModules`, and `darwinModules` are defined separately, leading to some duplication, especially for `home-manager` and core modules.

**Proposed Change:**
Refactor `flake.nix` to define a `baseModules` set that applies to all systems. Each machine configuration will then just add the modules specific to it. This will make it much clearer what configuration each machine is getting.

For example, `nixosConfigurations` and `darwinConfigurations` would look something like this:

```nix
let
  # Base modules for all systems
  baseModules = [
    home-manager.nixosModules.home-manager # for NixOS
    home-manager.darwinModules.home-manager # for Darwin
    ./modules/core
    ./modules/development
    # ... other shared modules
  ];
in {
  nixosConfigurations = {
    legion = nixpkgs.lib.nixosSystem {
      # ...
      modules = baseModules ++ [ ./modules/graphical ./machines/legion/default.nix ];
    };
    ghost = nixpkgs.lib.nixosSystem {
      # ...
      modules = baseModules ++ [ ./modules/wsl ./machines/ghost/default.nix ];
    };
  };

  darwinConfigurations = {
    darwin = darwin.lib.darwinSystem {
      # ...
      modules = baseModules ++ [ ./modules/darwin ./machines/darwin/default.nix ];
    };
  };
}
```

This change will be the foundation for making the configuration more homogeneous.

### 2. Integrate Darwin Configuration

The Darwin configuration is currently separate and needs to be integrated.

**Current Situation:**
The `darwinModules` list in `flake.nix` is very minimal and doesn't share code with the NixOS hosts.

**Proposed Change:**
By unifying module loading as described above, the Darwin machine will be able to use the same `home-manager` modules from `modules/core` and `modules/development` as the NixOS machines. This means the same shell (zsh, starship), tools (fzf, ripgrep), and development environment can be configured from one place for both macOS and NixOS.

### 3. Refactor Custom `dc-tec` Options

The custom `dc-tec` option set will be leveraged more effectively.

**Current Situation:**
Features are enabled/disabled per-machine in files like `machines/legion/default.nix`.

**Proposed Change:**
Use the `dc-tec` options to manage differences between systems more cleanly. For example, instead of having a separate `modules/wsl` that disables graphical features, checks can be added within modules like `lib.mkIf config.dc-tec.graphical.enable`. This will allow for the removal of the separate `wslModules` list.

### 4. Improve Package Management

A small but important improvement for reproducibility will be made.

**Current Situation:**
In `pkgs/niks/default.nix`, `vendorHash = null;` is used, which can be impure and less reproducible.

**Proposed Change:**
The correct `vendorHash` for the `niks-cli` Go package will be calculated and added to the package definition. This will ensure that the build is fully reproducible. The `sha256` for the source will also be updated.

### 5. Standardize Machine Configurations

The same principle of finding common parts and abstracting them will be applied to machine-specific configurations.

**Current Situation:**
The files in `machines/` contain per-machine configuration, with some potential for duplication.

**Proposed Change:**
Review the configurations for `chad`, `legion`, `ghost`, and `darwin` to identify common settings (like `networking` or user settings). These will be moved into a shared module under `modules/core` to further reduce duplication.

### 6. Update Documentation

The documentation will be updated to reflect the changes.

**Current Situation:**
The `README.md` describes the old structure.

**Proposed Change:**
The `README.md` will be updated to explain the new, unified module structure and how to manage the systems with it. The note about the Darwin configuration being separate will be removed.

### Next Steps

The implementation will proceed step-by-step, starting with the refactoring of `flake.nix` to unify module loading.
