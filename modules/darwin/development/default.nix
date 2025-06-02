{ pkgs, ... }:
{
  imports = [
    ./git.nix
  ];

  home-manager.users.roelc = {
    home = {
      packages = with pkgs; [
        awscli2
        go
        tenv
        terraform-docs
        powershell
        yaml-language-server
        talosctl
        kubectl
        kubernetes-helm
        kustomize
        argocd
        cilium-cli
        kubeseal
        kubescape
        rakkess
        kubectl-cnpg
        kube-linter
        bats
        helm-docs
        uv
        devenv
      ];
    };
  };
}
