{
  config,
  lib,
  pkgs,
  publicKeys,
  ...
}:
{
  imports = [ ./hardware.nix ];

  networking = {
    hostName = "chad";
    hostId = "a51b205b";
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
    ];
    useDHCP = false;
    firewall.allowedTCPPorts = [ 22 ];
    interfaces.br0 = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = "10.0.10.183";
          prefixLength = 24;
        }
      ];
    };
    interfaces.enp27s0.useDHCP = false;
    defaultGateway = {
      address = "10.0.10.1";
      interface = "br0";
    };
    bridges.br0.interfaces = [ "enp27s0" ];
  };

  boot = {
    supportedFilesystems = [ "zfs" ];
    initrd = {
      availableKernelModules = [ "r8169" ];
      network = {
        enable = true;
        # Stage 2 assigns the address to br0 instead of the physical NIC.
        flushBeforeStage2 = true;
        ssh = {
          enable = true;
          port = 2222;
          authorizedKeys = [ publicKeys.ssh.roelc ];
          hostKeys = [ "/data/etc/ssh/initrd_ssh_host_ed25519_key" ];
          extraConfig = ''
            AddressFamily inet
            DisableForwarding yes
            PermitRootLogin prohibit-password
            ForceCommand /bin/systemd-tty-ask-password-agent --watch
          '';
        };
      };
      systemd = {
        enable = true;
        extraBin.systemd-tty-ask-password-agent = "${config.boot.initrd.systemd.package}/bin/systemd-tty-ask-password-agent";
        network = {
          enable = true;
          # Use only the physical NIC for unlocking. The generated bridge
          # configuration belongs to stage 2.
          netdevs = lib.mkForce { };
          networks = lib.mkForce {
            "10-chad-lan" = {
              matchConfig.MACAddress = "00:d8:61:0e:e4:87";
              address = [ "10.0.10.183/24" ];
              routes = [ { Gateway = "10.0.10.1"; } ];
              networkConfig = {
                DHCP = "no";
                DNS = [
                  "1.1.1.1"
                  "1.0.0.1"
                ];
              };
              linkConfig.RequiredForOnline = "routable";
            };
          };
        };
      };
    };
    zfs = {
      devNodes = "/dev/disk/by-id";
      forceImportRoot = false;
      requestEncryptionCredentials = true;
    };
    loader.systemd-boot.configurationLimit = 5;
  };

  # Remove any IPv4 address inherited from the initramfs before the bridge
  # takes ownership of the host address and its connected route.
  systemd.services.br0-netdev.preStart = ''
    ${pkgs.iproute2}/bin/ip -4 address flush dev enp27s0
  '';

  # Keep the deployed mount locations. Moving these directories would hide
  # existing data when the corresponding bind mounts become active.
  environment.persistence = {
    "/data" = {
      hideMounts = true;
      directories = [
        "/var/lib/nixos"
        {
          directory = "/root/.ssh";
          mode = "0700";
        }
      ];
      users.roelc.directories = [
        {
          directory = ".ssh";
          mode = "0700";
        }
        ".gnupg"
        "documents"
        "pictures"
        "music"
        "videos"
      ];
    };
    "/cache" = {
      hideMounts = true;
      directories = [
        "/var/lib/libvirt"
        "/root/.local/share/autojump"
        "/root/.local/share/direnv"
      ];
      users.roelc.directories = [
        ".azure"
        ".cache"
        ".config"
        ".cloudflared"
        ".gh"
        ".local"
        ".mozilla"
        ".tenv"
        "downloads"
        "local/share/direnv"
        "projects"
      ];
    };
  };

  # Retain the deployed local passwords and avoid resetting the root dataset
  # while migrating from the workstation configuration.
  users.mutableUsers = lib.mkForce true;
  users.users = {
    root.hashedPassword = lib.mkForce null;
    roelc = {
      isNormalUser = true;
      uid = 1000;
      group = "users";
      description = "Roel de Cort";
      extraGroups = [
        "wheel"
        "libvirtd"
        "systemd-journal"
      ];
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = [ publicKeys.ssh.roelc ];
    };
  };
  programs.zsh.enable = true;
  security.sudo.enable = lib.mkForce false;
  security.doas = {
    enable = true;
    extraRules = [
      {
        users = [ "roelc" ];
        noPass = true;
      }
    ];
  };

  services.openssh.hostKeys = [
    {
      path = "/data/etc/ssh/ssh_host_rsa_key";
      type = "rsa";
      bits = 4096;
    }
    {
      path = "/data/etc/ssh/ssh_host_ed25519_key";
      type = "ed25519";
    }
  ];
  services.zfs = {
    autoScrub.enable = true;
    trim.enable = true;
  };

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      swtpm.enable = true;
      runAsRoot = false;
    };
    onBoot = "start";
    onShutdown = "shutdown";
  };

  # Keep the previous system closure available until the upgrade is verified.
  nix.gc.automatic = lib.mkForce false;
  environment.systemPackages = with pkgs; [
    ethtool
    pciutils
    usbutils
  ];
  time.timeZone = "Europe/Amsterdam";
  i18n.defaultLocale = "en_IE.UTF-8";
  system.stateVersion = "24.05";
}
