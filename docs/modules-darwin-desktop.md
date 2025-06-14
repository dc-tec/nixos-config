# Darwin Desktop Environment

Turn macOS into a productive, keyboard-driven workspace – without sacrificing the native look-and-feel. This module bundles a handful of open-source tools that work together to provide tiling window management, a scriptable status bar, powerful keyboard shortcuts and a few niceties around the edges.

---

## What you get

| Component        | What it does                                                     |
| ---------------- | ---------------------------------------------------------------- |
| **Yabai**        | Tiling window manager – snaps windows into a grid, Vim-like keys |
| **skhd**         | Global hot-key daemon that drives Yabai & launches apps          |
| **SketchyBar**   | Replaces the menu bar with a fully scriptable status bar         |
| **JankyBorders** | Draws subtle borders around focused windows                      |
| **GPG setup**    | Pre-configured GPG agent, pinentry integration on macOS          |

All of the above are installed and configured through Home-Manager – no manual tweaks required.

---

## How it works under the hood

1. **`modules/darwin/desktop/default.nix`** pulls in the individual sub-modules listed below.
2. Each sub-module ships sane defaults and only exposes the options you might actually want to tune. 3.`sketchybar` and `borders` are installed via Homebrew and started automatically by launchd.

```
desktop/
├── default.nix         # glue module – imports everything below
├── yabai.nix           # Yabai configuration & service definition
├── skhd.nix            # Hot-keys that control Yabai or launch apps
├── sketchybar/         # Status bar config, items & plugins
├── jankyborders/       # Border colours & service wrapper
├── gpg/                # GPG agent & pinentry settings
└── files/              # Static assets (plists, icons, …)
```

---

## Highlights

### Yabai – Tiling window manager

- Instant tiling: new windows are placed automatically.
- Move / resize windows with **hjkl** – feels just like Vim.
- Works with Mission Control desktops & full-screen apps.
- Per-display layouts so your external monitor can float while the laptop screen tiles.

### skhd – Hot-key daemon

- Consistent **cmd + alt + …** keybindings to focus, swap or resize windows.
- Quickly launch your favourite apps (e.g. **cmd + alt + C** opens Calendar).
- All hot-keys live in `skhd.nix` – tweak them to fit your muscle memory.

### SketchyBar – Scriptable status bar

- Shows Wi-Fi, battery, volume, time and more at a glance.
- Pulls workspace (space) information directly from Yabai.
- Widgets are plain shell scripts – add your own in `sketchybar/items`.
- Themeable via a central colours file that follows the Catppuccin palette.

### JankyBorders

- Thin borders around the focused window make it obvious where your cursor is.
- Border colour matches the current Catppuccin flavour.

### GPG integration

- Uses the GUI pinentry program on macOS so passphrases are requested once and cached.
- The agent is started automatically; no `gpgconf --kill gpg-agent` ever again.

---

## Customising your setup

Feel free to override any of the defaults in your host-specific config. Common tweaks:

- Change Yabai layouts or gaps in `yabai.nix`.
- Swap hot-keys in `skhd.nix` if they clash with another app.
- Add or remove status-bar items by editing the shell scripts in `sketchybar/items`.
- Adjust colours in `sketchybar/colors.sh` or border thickness in `jankyborders/bordersrc`.

Because everything is declarative you can experiment freely – just run `darwin-rebuild switch` to apply changes and go back at any time.

---

## Service management

| Service label | Manages            | How to control        |
| ------------- | ------------------ | --------------------- | ---- | -------------------- |
| `sketchybar`  | Status bar widgets | `brew services {start | stop | restart} sketchybar` |
| `borders`     | Window borders     | `brew services {start | stop | restart} borders`    |

Both services start automatically at boot once the module is enabled.

---

## Getting started

Add the module to your host's flake inputs and switch your system:

```nix
# On your macOS host flake
{
  imports = [
    ../modules/darwin/desktop
  ];
}
```

Then rebuild the system:

```bash
$ darwin-rebuild switch --flake .
```

Log out and back in (or `brew services restart --all`) to let the window manager take over – enjoy your brand-new tiling workflow!
