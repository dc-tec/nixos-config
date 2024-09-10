{...}: {
  imports = [./hardware.nix];

  networking = {
    hostName = "chad";
    hostId = "a51b205b";
    nameservers = ["1.1.1.1" "1.0.0.1"];
    extraHosts = ''
      172.50.0.101  argocd.decort.tech
      172.50.0.102  longhorn.decort.tech
    '';
  };

  dc-tec = {
    stateVersion = "24.05";
    core = {
      persistence = {
        enable = true;
      };
      zfs = {
        enable = true;
        encrypted = true;
        rootDataset = "rpool/local/root";
      };
      wireless = {
        enable = false;
      };
      cloudflared = {
        enable = true;
      };
    };
    development = {
      virtualisation = {
        docker.enable = true;
        k8s.enable = true;
        hypervisor.enable = true;
      };
    };
    graphical = {
      enable = true;
      laptop = false;
      hyprland = {
        enable = true;
      };
      xdg = {
        enable = true;
      };
    };
  };
}
