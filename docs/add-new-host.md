# Adding New Hosts

This guide explains how to add a new machine configuration to the NixOS/Darwin system configuration.

## Prerequisites

- Access to the target machine
- Hardware information (if adding a NixOS system)
- Understanding of the machine's intended purpose and configuration needs

## Step-by-Step Process

### 1. Create Machine Directory

Create a new directory for your machine under `machines/`:

```bash
mkdir machines/[machine-name]
cd machines/[machine-name]
```

### 2. Generate Hardware Configuration (NixOS Only)

For NixOS systems, generate the initial hardware configuration:

```bash
# On the target machine
nixos-generate-config --show-hardware-config > hardware-configuration.nix
```

Copy this file to your `machines/[machine-name]/` directory.

### 3. Create Machine Configuration

Create a `default.nix` file in your machine directory:

```nix
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    # Include hardware configuration (NixOS only)
    ./hardware-configuration.nix

    # Add any machine-specific modules
    # ./custom-module.nix
  ];

  # Set state version
  dc-tec.stateVersion = "24.05";

  # Configure user settings
  dc-tec.user = {
    name = "your-username";
    fullName = "Your Full Name";
    email = "your@email.com";
  };

  # Enable desired modules
  dc-tec = {
    # Add your specific module configurations here
  };

  # System-specific configuration
  networking.hostName = "machine-name";

  # Add any additional system configuration
}
```

### 4. Add to Flake Configuration

Edit `flake.nix` and add your new machine to the appropriate outputs section:

#### For NixOS machines:

```nix
nixosConfigurations = {
  # ... existing machines ...

  your-machine = nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit inputs outputs;
      lib = lib "x86_64-linux";  # or "aarch64-linux"
    };
    modules = sharedModules ++ nixosModules ++ [ ./machines/your-machine/default.nix ];
  };
};
```

#### For Darwin machines:

```nix
darwinConfigurations = {
  # ... existing machines ...

  your-machine = darwin.lib.darwinSystem {
    specialArgs = {
      inherit inputs outputs;
      lib = lib "aarch64-darwin";  # or "x86_64-darwin"
    };
    modules = sharedModules ++ darwinModules ++ [ ./machines/your-machine/default.nix ];
  };
};
```

### 5. Configure Machine-Specific Settings

Customize your machine configuration based on its intended use:

#### Development Workstation

```nix
dc-tec.development = {
  enable = true;
  languages = {
    go.enable = true;
    python.enable = true;
    nodejs.enable = true;
  };
};
```

#### Server System

```nix
dc-tec.services = {
  ssh.enable = true;
  # Add other server services
};
```

#### Desktop System

```nix
dc-tec.desktop = {
  enable = true;
  # Configure desktop environment
};
```

### 6. Build and Test

Test your configuration:

```bash
# For NixOS
sudo nixos-rebuild test --flake .#your-machine

# For Darwin
darwin-rebuild check --flake .#your-machine
```

### 7. Deploy Configuration

Once tested, deploy the configuration:

```bash
# For NixOS
sudo nixos-rebuild switch --flake .#your-machine

# For Darwin
darwin-rebuild switch --flake .#your-machine
```

### 8. Configure SOPS Secrets

Set up SOPS for secrets management on your new machine:

#### Generate Age Keys

```bash
# Age keys are automatically generated, but you can create them manually
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt

# Get the public key for adding to .sops.yaml
age-keygen -y ~/.config/sops/age/keys.txt
```

#### Add Public Key to Configuration

Add your machine's public key to the `.sops.yaml` file in the repository root:

```yaml
keys:
  - &your_machine_key age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
creation_rules:
  - path_regex: secrets/secrets.yaml$
    key_groups:
      - age:
          - *your_machine_key
```

#### Update Secrets File

Re-encrypt secrets to include your new key:

```bash
sops updatekeys secrets/secrets.yaml
```

#### Machine-Specific Secrets

If your machine needs specific secrets, add them to the secrets file:

```bash
sops secrets/secrets.yaml
```

For detailed SOPS management instructions, see the [SOPS Documentation](sops.html).

### 9. Document Your Machine

Create documentation for your new machine in `docs/machines/your-machine.md` following the format of existing machine documentation.

## Common Configuration Patterns

### Laptop Configuration

- Enable power management
- Configure display settings
- Set up wireless networking

### Server Configuration

- Disable desktop environment
- Enable SSH and remote access
- Configure firewall rules
- Set up monitoring and logging

### Development Machine

- Enable development tools
- Configure container support
- Set up language toolchains
- Enable virtualization

## Troubleshooting

### Build Failures

- Check syntax in your `default.nix`
- Ensure all imported modules exist
- Verify hardware configuration is correct

### Module Conflicts

- Review enabled modules for conflicts
- Check module documentation for requirements
- Use `lib.mkForce` to override conflicting options

### Hardware Issues

- Regenerate hardware configuration
- Check hardware-specific module requirements
- Review kernel and driver settings

## Next Steps

After successfully adding your machine:

1. Update the documentation index
2. Test the configuration thoroughly
3. Add any machine-specific secrets to SOPS
4. Configure backups and maintenance schedules
