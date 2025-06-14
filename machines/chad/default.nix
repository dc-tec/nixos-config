{...}: {
  imports = [./hardware.nix];

  networking = {
    hostName = "chad";
    hostId = "a51b205b";
    nameservers = ["1.1.1.1" "1.0.0.1"];
    useDHCP = false;
    interfaces = {
      br0 = {
        useDHCP = true;
        #ipv4.addresses = [
        #  {
        #    address = "10.0.1.125";
        #    prefixLength = 24;
        #  }
        #];
      };
      enp27s0 = {
        useDHCP = true;
      };
    };
    defaultGateway = "10.0.10.1";
    bridges = {
      "br0" = {
        interfaces = ["enp27s0"];
      };
    };
    extraHosts = ''
      10.0.10.151  argocd.decort.tech
      10.0.10.152  longhorn.decort.tech
      10.0.10.153  vault.decort.tech
    '';
  };

  dc-tec = {
    stateVersion = "24.05";
    persistence.enable = true;
    core = {
      zfs = {
        enable = true;
        encrypted = true;
        rootDataset = "rpool/local/root";
      };
      wireless = {
        enable = false;
      };
    };
    development = {
      virtualisation = {
        docker.enable = true;
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
