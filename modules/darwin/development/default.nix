{pkgs, ...}: {
  imports = [
    ./git.nix
  ];

  home-manager.users.roelc = {
    home.packages = with pkgs; [
      ansible-lint
      awscli2
      azure-cli
      go
      packer
      consul
      tenv
      terraform-docs
      consul
      packer
      powershell
      yaml-language-server
      talosctl
      kubectl
      kubernetes-helm
      kustomize
      argocd
      cilium-cli
      kubeseal
    ];
  };
}
