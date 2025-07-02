# Overlays

Think of overlays as a way to customize and extend the packages available across all your systems. They're like adding extra shelves to your package library - you get access to more options without losing what you already have.

## What We've Got

### Stable Packages Overlay

Sometimes the bleeding-edge packages in unstable break or don't work quite right. That's where our stable packages overlay comes in handy. It gives you access to the rock-solid packages from the stable NixOS channel, so you have options when things go sideways.

You'll want to use this when:

- A package in unstable is broken or causing issues
- You need a specific stable version that plays nice with other tools
- You're curious about the differences between stable and unstable versions

#### How to Use It

Once the overlay is set up, you can grab any stable package by adding `stable.` before the package name. It's that simple!

```nix
{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Instead of using the unstable version
  # environment.systemPackages = [ pkgs.somePackage ];

  # Use the stable version instead
  environment.systemPackages = [ pkgs.stable.somePackage ];
}
```

Here's a real example from when `devenv` was having build issues:

```nix
# In modules/shared/development/packages.nix
(lib.optionals config.dc-tec.development-packages.tools.dev [
  pkgs.stable.devenv  # Temporarily using stable version due to build failure
  httpie
  nodejs
  # ... other packages
])
```

#### How It's Set Up

Don't worry, the overlay is already configured and ready to use! But if you're curious, here's what's happening behind the scenes.

The overlay is defined in `overlays/default.nix`:

```nix
{inputs, ...}: {
  stable-packages = final: prev: {
    stable = import inputs.nixpkgs-stable {system = final.system;};
  };
}
```

And it gets automatically applied to all your systems through the shared configuration in `flake.nix`:

```nix
sharedModules = [
  ({inputs, outputs, lib, config, pkgs, ...}: {
    nixpkgs = {
      overlays = [
        (import ./overlays { inherit inputs; }).stable-packages
      ];
    };
  })
  # ... other modules
];
```

### Custom Packages Overlay

We also have a custom packages overlay that gives you access to any packages we've built ourselves. These live in the `pkgs/` directory and are ready to use.

#### How to Use Them

Custom packages work just like regular packages - no special prefix needed:

```nix
environment.systemPackages = [ pkgs.niks ];  # Custom package from pkgs/
```

## Tips and Tricks

**Leave breadcrumbs for yourself**
When you switch to a stable package because of issues, leave a comment so future-you knows why:

```nix
pkgs.stable.packageName  # Temporarily using stable due to build failure in unstable
```

**Think about your production systems**
For critical systems, you might want to stick with stable versions of important packages rather than riding the unstable wave.

**Test before you commit**
When switching between stable and unstable versions, give things a test run. Package versions and their dependencies can be quite different, so what works with one might not work with the other.

**Document the why**
If you're switching to stable for a specific reason (especially temporary fixes), make a note of it. Your future self (and your teammates) will thank you.

## When Things Go Wrong

**Package won't build in unstable?**
First, check if the stable version works: `nix-env -f '<nixpkgs>' -qaP packageName`. If it does, switch temporarily with `pkgs.stable.packageName`. While you're at it, consider letting the maintainers know about the issue if it looks like a regression. Keep an eye out for fixes and switch back when things are working again.

**Package doesn't exist in stable?**
Some packages are too new or experimental for stable. In that case, you can try building from source if it's critical, or look for alternative packages that do what you need.
