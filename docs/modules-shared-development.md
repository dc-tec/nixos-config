# Shared Development Packages

Every developer workstation – whether it runs NixOS, WSL2, or macOS – should start with the same solid toolbox.  
This module provides that toolbox in a single, opt-in bundle so you can pick exactly the languages and utilities you need and ignore the rest.

## Highlights

- Unified experience on Linux **and** Darwin
- Simple opt-in groups (`dc-tec.development-packages.tools.<group> = true`)  
  (e.g. `go`, `python`, `k8s`, `security`, …)
- Pre-configured Git, LSP servers, linters and modern CLI replacements
- Cloud & infrastructure tooling for Terraform, Kubernetes and the major public clouds

## Quick start

Enable the module and select the groups you care about:

```nix
{
  dc-tec.development-packages = {
    enable = true;

    # Pick any combination of groups
    tools = {
      go        = true;  # Go compiler + tooling
      python    = true;  # Python 3 + LSP + Ruff
      iac       = true;  # Terraform, Ansible, …
      k8s       = true;  # kubectl, helm, kustomize, …
      cloud     = true;  # AWS, Azure & Hetzner CLIs
      dev       = true;  # just, httpie, pre-commit, …
      infra     = true;  # HashiCorp Boundary / Consul / Nomad
      security  = true;  # Vault, OpenBao
      database  = true;  # PostgreSQL client
      networking = true; # (reserved – coming soon)
    };
  };
}
```

> All packages are installed through **Home-Manager**, so they live in the user profile and can be easily updated or removed.

## Package groups

### Go (`tools.go`)

- `go`, `gopls`, `golangci-lint`, `gosec`, `goreleaser`

### Python (`tools.python`)

- `python3`, `python-lsp-server`, `python-lsp-ruff`, `uv`

### Infrastructure-as-Code (`tools.iac`)

- `tenv`, `terraform-docs`, `tflint`, `terraform-ls`
- `ansible`, `ansible-builder`, `ansible-lint`

### Kubernetes (`tools.k8s`)

- `kubectl`, `helm`, `kustomize`, `kube-linter`, `kubescape`
- `argocd`, `cilium-cli`, `kubectl-cnpg`, `kubeseal`, `talosctl`
- Local clusters: `k3d`, `kind`
- Docs & RBAC helpers: `helm-docs`, `rakkess`

### Cloud (`tools.cloud`)

- `awscli2`, `azure-cli`, `hcloud`

### Developer tools (`tools.dev`)

- `devenv`, `just`, `pre-commit`, `httpie`, `bats`, `yaml-language-server`, `powershell`, `nodejs`

### Infrastructure (`tools.infra`)

- `packer`, `boundary`, `consul`, `nomad`

### Security (`tools.security`)

- `vault`, `openbao`

### Database (`tools.database`)

- `postgresql` client and utilities

## Behind the scenes

The module lives at `modules/shared/development/{packages,git}.nix` and is imported through
`modules/shared/development/default.nix`. When enabled it:

1. Defines the option set under `dc-tec.development-packages.*`.
2. Installs the selected package groups to the **user profile** via Home-Manager.
3. Provides sensible Git defaults (signature enforcement, email per-project, etc.).

Feel free to cherry-pick only the parts you need. Everything is optional and composable.
