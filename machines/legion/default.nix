{...}: {
  imports = [./hardware.nix];

  networking = {
    hostName = "legion";
    hostId = "6eea4e84";
    nameservers = ["1.1.1.1" "1.0.0.1"];
  };

  dc-tec = {
    stateVersion = "24.05";
    gpg.enable = true;
    persistence.enable = true;
    core = {
      zfs = {
        enable = true;
        encrypted = true;
        rootDataset = "rpool/local/root";
      };
      wireless = {
        enable = true;
      };
    };
    graphical = {
      enable = true;
      laptop = true;
      hyprland = {
        enable = true;
      };
      xdg = {
        enable = true;
      };
    };
  };
}
