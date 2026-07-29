{
  lib,
  pkgs,
  ...
}:
{
  nix = {
    channel.enable = false;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    optimise = {
      automatic = true;
      dates = [ "weekly" ];
    };
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [
        "root"
        "@wheel"
      ];
    };
  };

  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = lib.mkDefault [ 22 ];
    };

    # Bootstrap default only. The physical interface and provider network
    # settings are captured after the server is powered on.
    useDHCP = lib.mkDefault true;
  };

  services = {
    fail2ban.enable = true;
    fstrim.enable = true;
    smartd.enable = true;

    openssh = {
      enable = true;
      openFirewall = false;
      settings = {
        KbdInteractiveAuthentication = false;
        PasswordAuthentication = false;
        PermitRootLogin = "no";
        X11Forwarding = false;
      };
    };
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  users = {
    mutableUsers = false;
    users.root.hashedPassword = "!";
  };

  environment.systemPackages = with pkgs; [
    curl
    git
    htop
    jq
    ripgrep
    smartmontools
    tmux
    vim
  ];

  boot.tmp.cleanOnBoot = true;
  system.autoUpgrade.enable = false;
  zramSwap.enable = true;
}
