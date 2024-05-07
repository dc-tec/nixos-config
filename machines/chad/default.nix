{...}: {
  imports = [./hardware.nix];

  networking = {
    hostName = "chad";
    hostId = "a51b205b";
    nameservers = ["1.1.1.1" "1.0.0.1"];
  };

  dc-tec = {
    stateVersion = "24.05";
    core = {
      zfs = {
        encrypted = true;
        rootDataset = "rpool/local/root";
      };
      wireless = {
        enable = false;
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
