# Darwin Module

Opinionated macOS configuration for `nix-darwin`. The module focuses on three areas:

1. **System defaults** – declaratively set Dock, Finder, Trackpad, etc.
2. **Package management** – Homebrew integration for apps, fonts & services.
3. **Optional desktop environment** – tiling window manager, status-bar and hot-keys (see [`Darwin Desktop`](modules-darwin-desktop.md)).

---

## Why use it?

- A reproducible macOS setup – wipe a machine, run `darwin-rebuild switch` and you are back in business.
- Single source of truth for both GUI apps (Homebrew) and command-line tools (Nix).
- Touch-ID enabled `sudo`, sensible key-repeat rates and other QoL tweaks baked in.

---

## Module layout

| Path         | Purpose                                                              |
| ------------ | -------------------------------------------------------------------- |
| `system.nix` | Core macOS preferences & security settings                           |
| `homebrew/`  | Taps, casks, services and auto-update configuration                  |
| `desktop/`   | Tiling WM (Yabai), hot-keys (skhd), status-bar (SketchyBar), borders |

The desktop sub-module is optional – import it only if you want a keyboard-driven workspace. It is documented in detail [here](modules-darwin-desktop.md).

---

## Key features

### System preferences (`system.nix`)

- Dock auto-hides on the **left** and shows no recent apps.
- Finder shows all files, file extensions and POSIX paths in the title bar.
- Trackpad: tap-to-click and two-finger secondary click enabled.
- Fast key repeat (`25 ms`) and reduced initial delay.
- Dark mode by default, natural scrolling disabled.
- Touch-ID authentication for `sudo`.

### Homebrew integration (`homebrew/`)

- Homebrew is installed and managed by the module – no manual install required.
- Automatic updates for both Homebrew itself and all installed formulae/casks.
- Binaries added to the `$PATH`, services managed via `brew services`.
- Large, curated package set for development, productivity and media.

### Desktop environment (`desktop/`)

A complete tiling setup powered by Yabai. If you enable it you will get:

- Tiling window management, global hot-keys, scriptable status bar.
- Thin focus borders and pre-configured GPG agent.

For full details see the dedicated [Darwin Desktop](modules-darwin-desktop.md) document.

---

## Usage

1. Add the module (and optionally the desktop sub-module) to your flake:

```nix
{
  imports = [
    ./modules/darwin
  ];
}
```

2. Rebuild the system:

```bash
$ darwin-rebuild switch --flake .
```

That's it – macOS preferences, packages and (optionally) the desktop environment are now managed declaratively.

---

## Customising

All settings can be overridden in your host flake. Common tweaks:

- Change Dock position or key-repeat in `system.nix`.
- Add or remove Homebrew packages in `homebrew/default.nix`.
- Tweak hot-keys or bar widgets in the `desktop/` folder.

Because `nix-darwin` is declarative you can experiment safely: run another rebuild to try a change; roll back if it didn't work.

---

## Requirements

- [`nix-darwin`](https://github.com/LnL7/nix-darwin)
