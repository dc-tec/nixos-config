In order to keep our system nice and tidy we can perform the following maintenance tasks:

```bash
nix-env --list-generations

nix-collect-garbage  --delete-old

nix-collect-garbage  --delete-generations 1 2 3

# recomeneded to sometimes run as sudo or doas to collect additional garbage
doas nix-collect-garbage -d

# As a separation of concerns - you will need to run this command to clean out boot
doas /run/current-system/bin/switch-to-configuration boot
```
