{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {
    dc-tec.development.k8s = {
      k3d.enable = lib.mkEnableOption "k3d";
    };
  };

  config = lib.mkIf config.dc-tec.development.k8s.k3d.enable {
    home-manager.users.roelc = {
      home.packages = with pkgs; [
        kube3d
        kubectl
        kubernetes-helm
        kustomize
        cilium-cli
      ];
    };
  };
}
