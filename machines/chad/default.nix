{...}: {
  imports = [./hardware.nix];

  networking = {
    hostName = "chad";
    hostId = "a51b205b";
    nameservers = ["1.1.1.1" "1.0.0.1"];
    useDHCP = false;
    interfaces = {
      br0 = {
        ipv4.addresses = [
          {
            address = "10.0.1.125";
            prefixLength = 24;
          }
        ];
      };
    };
    defaultGateway = "10.0.1.1";
    bridges = {
      "br0" = {
        interfaces = ["enp27s0"];
      };
    };
    extraHosts = ''
      172.50.0.101  argocd.decort.tech
      172.50.0.102  longhorn.decort.tech
      172.50.0.103  password.decort.tech
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
      vscode-server.enable = true;
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
