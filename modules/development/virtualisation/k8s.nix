{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {
    dc-tec.development.virtualisation = {
      k8s.enable = lib.mkEnableOption "k8s tooling";
    };
  };

  config = lib.mkIf config.dc-tec.development.virtualisation.k8s.enable {
    home-manager.users.roelc = {
      home.packages = with pkgs; [
        talosctl
        kubectl
        kubernetes-helm
        kustomize
        argocd
        cilium-cli
      ];

      programs.k9s = {
        enable = true;
        catppuccin = {
          enable = true;
          flavor = "macchiato";
        };
      };
    };
  };
}
