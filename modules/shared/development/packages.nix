{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    dc-tec.development-packages = {
      enable = lib.mkEnableOption "shared development packages";
      tools = {
        go = lib.mkEnableOption "Go development";
        python = lib.mkEnableOption "Python development";
        iac = lib.mkEnableOption "IaC tools";
        k8s = lib.mkEnableOption "Kubernetes tools";
        cloud = lib.mkEnableOption "Cloud tools";
        dev = lib.mkEnableOption "Dev Tools";
        infra = lib.mkEnableOption "Infrastructure tools";
        security = lib.mkEnableOption "Security tools";
        networking = lib.mkEnableOption "Networking tools";
        database = lib.mkEnableOption "Database tools";
      };
    };
  };

  config = lib.mkIf config.dc-tec.development-packages.enable {
    home-manager.users.${config.dc-tec.user.name} = {
      home.packages =
        with pkgs;
        lib.flatten [
          # Go Tools
          (lib.optionals config.dc-tec.development-packages.tools.go [
            go
            gopls
            golangci-lint
            gosec
            goreleaser
          ])
          # Python Tools
          (lib.optionals config.dc-tec.development-packages.tools.python [
            python3
            python3Packages.python-lsp-server
            python3Packages.python-lsp-ruff
            uv
          ])
          # IaC Tools
          (lib.optionals config.dc-tec.development-packages.tools.iac [
            tenv
            terraform-docs
            tflint
            terraform-ls
            ansible
            ansible-builder
            ansible-lint
          ])
          # K8s Tools
          (lib.optionals config.dc-tec.development-packages.tools.k8s [
            kubectl
            kubernetes-helm
            kustomize
            argocd
            cilium-cli
            kubectl-cnpg
            kubeseal
            talosctl
            kube-linter
            kubescape
            helm-docs
            k3d
            kind
            rakkess
          ])
          # Cloud CLI Tools
          (lib.optionals config.dc-tec.development-packages.tools.cloud [
            awscli2
            azure-cli
            hcloud
          ])
          # Dev Tools
          (lib.optionals config.dc-tec.development-packages.tools.dev [
            devenv
            httpie
            nodejs
            pre-commit
            just
            bats
            yaml-language-server
            powershell
          ])
          # Infrastructure Tools
          (lib.optionals config.dc-tec.development-packages.tools.infra [
            packer
            boundary
            consul
            nomad
          ])
          # Security Tools
          (lib.optionals config.dc-tec.development-packages.tools.security [
            vault
            openbao
          ])
          # Database Tools
          (lib.optionals config.dc-tec.development-packages.tools.database [
            postgresql
          ])
        ];
    };
  };
}