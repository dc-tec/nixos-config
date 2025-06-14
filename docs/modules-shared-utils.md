# Shared Utilities & Command-Line Tools

All machines managed by this flake come with a carefully curated set of small but powerful command-line programs. The goal is to provide a consistent and delightful developer experience on both NixOS and macOS (Darwin).

---

## Why these tools?

- A predictable environment across every computer you log in to.
- Fast and modern replacements for the ageing default utilities.
- Sensible defaults and the lovely Catppuccin colour palette out-of-the-box.

---

## How packages are installed

1. **System packages** – added to `environment.systemPackages`, they are available to every user.
2. **User packages** – installed with Home-Manager so each user gets their own copy and can opt-out if desired.

The lists below are grouped by purpose so you can quickly see what is installed and why.

---

## System packages

| Package(s)              | Purpose                                   |
| ----------------------- | ----------------------------------------- |
| wget / curl             | Download files over HTTP / HTTPS          |
| coreutils               | GNU core utilities (`ls`, `cp`, `mv`, …)  |
| unzip                   | Extract `.zip` archives                   |
| openssl                 | Cryptographic toolkit and SSL/TLS helpers |
| dnsutils                | DNS look-ups (`dig`, `nslookup`)          |
| nmap                    | Port scanner and network exploration      |
| util-linux              | Assorted low-level system utilities       |
| whois                   | Query domain registration information     |
| moreutils               | Additional Unix toys such as `sponge`     |
| git                     | Distributed version control               |
| age / sops / ssh-to-age | Encryption and secrets management         |
| tcpdump                 | Network packet capture                    |
| nvd                     | Diff Nix package versions                 |

---

## User packages (Home-Manager)

| Package    | Purpose                                                  |
| ---------- | -------------------------------------------------------- |
| tlrc       | A colourful `tldr` client                                |
| fontconfig | Font configuration utilities                             |
| fd         | Faster alternative to `find`                             |
| jq / yq    | JSON and YAML processors                                 |
| direnv     | Automatic loading of `.envrc` files                      |
| atac       | REST & GraphQL API tester                                |
| comma      | Run a binary from the Nix registry without installing it |
| autojump   | Smart directory jumping                                  |
| ollama     | Local LLM manager                                        |
| nixvim     | Custom Neovim distribution                               |

---

## Modules that add extra configuration

Some programs benefit from additional setup. The `.nix` files in this folder provide sensible defaults, shell integrations and themed output.

| Module       | What it configures                                               |
| ------------ | ---------------------------------------------------------------- |
| zsh.nix      | Z-shell with plugins, aliases and Catppuccin syntax highlighting |
| starship.nix | Beautiful prompt with Git integration                            |
| kitty.nix    | GPU-accelerated terminal with transparency & blur on macOS       |
| direnv.nix   | Enables `direnv` and hooks it into Zsh                           |
| eza.nix      | Modern replacement for `ls` with icons                           |
| yazi.nix     | TUI file manager                                                 |
| zoxide.nix   | Jump to directories you visit regularly                          |
| fzf.nix      | Fuzzy finder wired into the shell                                |
| bat.nix      | Syntax-highlighted `cat` replacement                             |
| ripgrep.nix  | Ultra-fast text search                                           |
| bottom.nix   | TUI resource monitor (think `htop` on caffeine)                  |
| k9s.nix      | Kubernetes dashboard in the terminal                             |
| ssh.nix      | Opinionated SSH client configuration                             |
| sops.nix     | Age + SOPS integration for secret management                     |
| nh.nix       | Quality-of-life helper for working with Nix flakes               |

---

## Cross-platform considerations

Each module contains conditional logic so that:

- File paths are correct on both Linux and macOS.
- Persistent data is stored on ZFS datasets when they are available.
- macOS-specific niceties, such as Keychain integration, Just Work™.

---

## Usage

After activating the system (`nixos-rebuild switch` or `darwin-rebuild switch`) the utilities are ready to use. Many come with handy aliases defined in `zsh.nix` – feel free to tweak them to your liking.
