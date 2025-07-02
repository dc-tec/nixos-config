# Troubleshooting Guide

This document contains solutions to common issues you might encounter with this NixOS/Darwin configuration.

## Nix Version Conflicts

### Problem: Build uses different nix version than configuration evaluates to

**Symptoms:**

- `nix eval .#darwinConfigurations.darwin.pkgs.nix.version` shows one version (e.g., 2.28.4)
- Build output shows building an older version (e.g., `nix-2.28.3.drv`)
- Terminal crashes or build failures with version mismatches

**Cause:**
A flake input is using its own pinned nixpkgs instead of following your main nixpkgs input with overlays applied.

**Solution:**

1. Identify which input is causing the issue by checking `flake.lock`
2. Update the problematic input to follow your main nixpkgs:
   ```nix
   # In flake.nix inputs
   problematic-input = {
     url = "github:owner/repo";
     inputs.nixpkgs.follows = "nixpkgs";
   };
   ```
3. Update the flake: `nix flake update problematic-input`

**Example:**

```nix
# Before
nixvim.url = "github:dc-tec/nixvim";

# After
nixvim = {
  url = "github:dc-tec/nixvim";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

## Build Issues

### Problem: "error: cached failure of attribute"

**Symptoms:**

- Builds fail with cached failure messages
- Previously working builds suddenly stop working

**Solutions:**

1. Clear the evaluation cache:

   ```bash
   nix store delete /nix/store/*-eval-cache*
   ```

2. Force rebuild without cache:
   ```bash
   nix build --rebuild .#darwinConfigurations.darwin.system
   ```

### Problem: Out of disk space during builds

**Symptoms:**

- "No space left on device" errors
- Large `/nix/store` directory

**Solutions:**

1. Run garbage collection:

   ```bash
   nix store gc --extra-experimental-features nix-command
   ```

2. Clean older generations:

   ```bash
   # Darwin
   sudo nix-env --delete-generations old --profile /nix/var/nix/profiles/system

   # NixOS
   sudo nix-collect-garbage --delete-older-than 7d
   ```

3. Optimize store:
   ```bash
   nix store optimise
   ```

## Home Manager Issues

### Problem: Home Manager activation fails with file conflicts

**Symptoms:**

- "File exists" errors during `darwin-rebuild switch`
- Conflicts with existing dotfiles

**Solutions:**

1. Enable backup file extension (already configured):

   ```nix
   home-manager.backupFileExtension = "backup";
   ```

2. Manually remove conflicting files:

   ```bash
   rm ~/.config/conflicting-file
   ```

3. Use `home-manager switch --backup-extension backup` for manual runs

### Problem: Home Manager options not applying

**Symptoms:**

- Configuration changes don't take effect
- Programs not installed despite being enabled

**Solutions:**

1. Check if the user configuration is properly imported:

   ```bash
   nix eval .#darwinConfigurations.darwin.config.home-manager.users.${USER}
   ```

2. Manually run home-manager:

   ```bash
   home-manager switch --flake .
   ```

3. Check for conflicting system-level and home-manager packages

## Darwin-Specific Issues

### Problem: "darwin-rebuild: command not found"

**Solution:**

```bash
# Install nix-darwin
nix run nix-darwin -- switch --flake .

# Or add to shell temporarily
nix shell nixpkgs#darwin-rebuild
```

### Problem: Homebrew apps not installing

**Symptoms:**

- Homebrew packages defined but not installed
- `brew list` doesn't show expected packages

**Solutions:**

1. Run Homebrew commands manually:

   ```bash
   /opt/homebrew/bin/brew bundle --file=/opt/homebrew/Brewfile
   ```

2. Check Homebrew configuration in `modules/darwin/homebrew/`

3. Ensure nix-homebrew is properly configured

### Problem: System preferences reset after rebuild

**Symptoms:**

- macOS system settings revert to defaults
- Dock, keyboard settings, etc. reset

**Solution:**
Review and update `modules/darwin/system.nix` to include desired system preferences.

## Flake Issues

### Problem: "error: flake 'path' does not provide attribute"

**Symptoms:**

- Cannot access flake outputs
- Attribute path errors

**Solutions:**

1. Check available outputs:

   ```bash
   nix flake show
   ```

2. Verify the attribute path:

   ```bash
   nix eval .#darwinConfigurations --apply builtins.attrNames
   ```

3. Check for typos in configuration names

### Problem: Flake inputs won't update

**Symptoms:**

- `nix flake update` doesn't change versions
- Stuck on old commits

**Solutions:**

1. Update specific inputs:

   ```bash
   nix flake update nixpkgs home-manager
   ```

2. Clear flake registry cache:

   ```bash
   rm -rf ~/.cache/nix/flake-registry.json
   ```

3. Force refresh:
   ```bash
   nix flake update --refresh
   ```

## SSH/SOPS Issues

### Problem: Cannot decrypt secrets

**Symptoms:**

- "failed to decrypt" errors
- SOPS-encrypted files unreadable

**Solutions:**

1. Check SSH key is in ssh-agent:

   ```bash
   ssh-add -l
   ```

2. Verify key is in `.sops.yaml`:

   ```bash
   sops --config .sops.yaml updatekeys secrets/secrets.yaml
   ```

3. Re-encrypt secrets with current keys:
   ```bash
   sops --config .sops.yaml -r secrets/secrets.yaml
   ```

## Using `nh` for Troubleshooting

The `nh` tool provides a better user experience for common NixOS/Darwin operations and is already configured in this setup.

### System Operations

```bash
# Switch to new configuration (equivalent to darwin-rebuild/nixos-rebuild switch)
nh os switch

# Test configuration without switching
nh os test

# Boot into new configuration (NixOS only)
nh os boot

# Show what would be built/downloaded
nh os switch --dry

# Switch with detailed output
nh os switch --verbose
```

### System Information

```bash
# Show system generations
nh os list

# Show current generation info
nh os list --current

# Show generation differences
nh os diff

# Show what packages would change
nh os diff --changes
```

### Cleaning and Maintenance

```bash
# Clean old generations (disabled by default in config)
nh clean all

# Clean with specific parameters
nh clean all --keep 5 --keep-since 7d

# Just show what would be cleaned
nh clean all --dry

# Clean user profiles
nh clean user

# Clean system profiles
nh clean system
```

### Home Manager Operations

```bash
# Switch home-manager configuration
nh home switch

# Test home-manager configuration
nh home test

# Show home-manager generations
nh home list

# Show home-manager differences
nh home diff
```

### Search and Information

```bash
# Search for packages
nh search firefox

# Show package information
nh search --details firefox

# Search with specific attributes
nh search --json firefox | jq
```

### Troubleshooting with `nh`

1. **Debug failed switches:**

   ```bash
   nh os switch --verbose --show-trace
   ```

2. **Check what's changed since last switch:**

   ```bash
   nh os diff --changes
   ```

3. **Rollback to previous generation:**

   ```bash
   nh os list  # Find previous generation number
   sudo /nix/var/nix/profiles/system-<number>-link/bin/switch-to-configuration switch
   ```

4. **Clean up after failed builds:**

   ```bash
   nh clean all --dry  # See what would be cleaned
   nh clean all --keep 3
   ```

5. **Check flake status:**
   ```bash
   nh os switch --dry  # Shows flake inputs and what would change
   ```

## General Debugging

### Check system status

```bash
# Using nh (recommended)
nh os switch --dry --verbose

# Traditional methods
# Darwin
darwin-rebuild --flake . switch --show-trace

# NixOS
nixos-rebuild --flake . switch --show-trace
```

### Evaluate configuration without building

```bash
nix eval .#darwinConfigurations.darwin.config --json | jq .
```

### Check derivation dependencies

```bash
nix show-derivation .#darwinConfigurations.darwin.system
```

### Enable debug output

```bash
nix build --print-build-logs --verbose .#darwinConfigurations.darwin.system
```

### Check for conflicting packages

```bash
# List all packages in environment
nix-env -q

# Check specific package source
nix eval .#darwinConfigurations.darwin.pkgs.packageName.meta
```

## Performance Tips

1. **Use binary caches**: Ensure binary caches are configured in `nix.settings.substituters`

2. **Parallel builds**: Set `nix.settings.max-jobs` appropriately for your hardware

3. **Build remotely**: Consider using remote builders for resource-intensive builds

4. **Pin dependencies**: Use `flake.lock` to ensure reproducible builds

5. **Minimal rebuilds**: Structure modules to minimize unnecessary rebuilds

## Getting Help

1. **Check logs**: Always check build logs for specific error messages
2. **Search issues**: Look for similar issues in relevant GitHub repositories
3. **Community**: Ask in NixOS Discord, Reddit, or Discourse
4. **Documentation**: Refer to official NixOS and Home Manager documentation

Remember to always backup your working configuration before making significant changes!
