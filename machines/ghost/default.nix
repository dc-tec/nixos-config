_: {
  networking = {
    hostName = "ghost";
    hostId = "3c4e8b4f";
  };

  dc-tec = {
    stateVersion = "24.05";
    wsl = {
      enable = true;
    };
    core = {
      zfs = {
        enable = false;
      };
      wireless = {
        enable = false;
      };
    };
    graphical = {
      enable = false;
    };
  };
}
