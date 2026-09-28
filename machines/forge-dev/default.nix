{
  lib,
  modulesPath,
  pkgs,
  publicKeys,
  ...
}:
let
  dataDevice = "/dev/disk/by-id/virtio-dev-data";
  cacheDevice = "/dev/disk/by-id/virtio-dev-cache";
  sshHostKey = "/srv/dev/ssh/ssh_host_ed25519_key";
  sshHostKeyStash = "/run/forge-dev-ssh-host-key";

  initializeDisks = pkgs.writeShellApplication {
    name = "forge-dev-initialize";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.e2fsprogs
      pkgs.systemd
      pkgs.util-linux
    ];
    text = ''
      if (( EUID != 0 )); then
        echo "forge-dev-initialize must run as root" >&2
        exit 1
      fi

      for device in ${dataDevice} ${cacheDevice}; do
        if [[ ! -b "$device" ]]; then
          echo "expected VM disk is missing: $device" >&2
          exit 1
        fi
      done

      if ! mountpoint --quiet /srv/dev && [[ -s ${sshHostKey} ]]; then
        install -d -m 0700 ${sshHostKeyStash}
        install -m 0600 ${sshHostKey} ${sshHostKeyStash}/ssh_host_ed25519_key
        if [[ -s ${sshHostKey}.pub ]]; then
          install -m 0644 ${sshHostKey}.pub ${sshHostKeyStash}/ssh_host_ed25519_key.pub
        fi
      fi

      needs_format=0
      for device in ${dataDevice} ${cacheDevice}; do
        filesystem="$(blkid --probe --output value --match-tag TYPE "$device" 2>/dev/null || true)"
        case "$filesystem" in
          "") needs_format=1 ;;
          ext4) ;;
          *)
            echo "$device contains an unexpected $filesystem filesystem; refusing to continue" >&2
            exit 1
            ;;
        esac
      done

      if (( needs_format )); then
        printf 'Type INITIALIZE forge-dev to format only the empty dev-data/dev-cache disks: '
        read -r confirmation
        if [[ "$confirmation" != "INITIALIZE forge-dev" ]]; then
          echo "initialization cancelled" >&2
          exit 1
        fi
      fi

      if ! blkid --probe --output value --match-tag TYPE ${dataDevice} >/dev/null 2>&1; then
        mkfs.ext4 -L forge-dev-data ${dataDevice}
      fi
      if ! blkid --probe --output value --match-tag TYPE ${cacheDevice} >/dev/null 2>&1; then
        mkfs.ext4 -L forge-dev-cache ${cacheDevice}
      fi

      if ! mountpoint --quiet /srv/dev; then
        mount /srv/dev
      fi
      if ! mountpoint --quiet /var/cache/dev; then
        mount /var/cache/dev
      fi

      install -d -m 0750 -o dev -g users \
        /srv/dev/home/dev \
        /srv/dev/projects
      install -d -m 0710 -o root -g docker /srv/dev/docker
      install -d -m 0755 -o root -g root /srv/dev/ssh
      install -d -m 0750 -o dev -g users /var/cache/dev/dev

      if [[ ! -s ${sshHostKey} ]]; then
        if [[ -s ${sshHostKeyStash}/ssh_host_ed25519_key ]]; then
          install -m 0600 ${sshHostKeyStash}/ssh_host_ed25519_key ${sshHostKey}
          if [[ -s ${sshHostKeyStash}/ssh_host_ed25519_key.pub ]]; then
            install -m 0644 ${sshHostKeyStash}/ssh_host_ed25519_key.pub ${sshHostKey}.pub
          fi
        elif [[ -s /etc/ssh/ssh_host_ed25519_key ]]; then
          install -m 0600 /etc/ssh/ssh_host_ed25519_key ${sshHostKey}
          if [[ -s /etc/ssh/ssh_host_ed25519_key.pub ]]; then
            install -m 0644 /etc/ssh/ssh_host_ed25519_key.pub ${sshHostKey}.pub
          fi
        fi
      fi

      systemctl restart sshd-keygen.service
      systemctl reload sshd.service
      rm -f \
        ${sshHostKeyStash}/ssh_host_ed25519_key \
        ${sshHostKeyStash}/ssh_host_ed25519_key.pub
      rmdir --ignore-fail-on-non-empty ${sshHostKeyStash}

      systemctl start docker.service
      echo "forge-dev disks are initialized; reconnect as dev to enter the encrypted home"
    '';
  };
in
{
  imports = [
    (modulesPath + "/profiles/minimal.nix")
    ./developer-shell.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  networking = {
    hostName = "forge-dev";
    useDHCP = false;
    useNetworkd = true;
    firewall.allowedTCPPorts = [ 22 ];
  };

  systemd.network = {
    enable = true;
    networks."10-forge-dev" = {
      matchConfig.MACAddress = "52:54:00:77:00:10";
      address = [ "10.78.0.10/24" ];
      routes = [ { Gateway = "10.78.0.1"; } ];
      networkConfig = {
        DNS = [
          "1.1.1.1"
          "9.9.9.9"
        ];
        IPv6AcceptRA = false;
      };
    };
  };
  systemd.services."serial-getty@ttyS0".wantedBy = [ "getty.target" ];
  systemd.tmpfiles.rules = [
    # cmux 0.64.22's remote SSH bootstrap hard-codes /bin/sleep. NixOS only
    # exposes coreutils through the system profile, so provide the one FHS path
    # it currently requires. `L` leaves a future native path untouched.
    "L /bin/sleep - - - - /run/current-system/sw/bin/sleep"
  ];
  services.resolved.enable = true;

  boot = {
    growPartition = true;
    kernelParams = [
      "console=tty0"
      "console=ttyS0,115200n8"
    ];
    initrd.availableKernelModules = [
      "virtio_blk"
      "virtio_net"
      "virtio_pci"
      "virtio_scsi"
      "tpm_crb"
    ];
    loader = {
      efi.canTouchEfiVariables = false;
      systemd-boot.enable = true;
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      autoResize = true;
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-label/ESP";
      fsType = "vfat";
    };
    "/srv/dev" = {
      device = dataDevice;
      fsType = "ext4";
      options = [
        "nofail"
        "x-systemd.device-timeout=10s"
      ];
    };
    "/var/cache/dev" = {
      device = cacheDevice;
      fsType = "ext4";
      options = [
        "nofail"
        "x-systemd.device-timeout=10s"
      ];
    };
  };

  users.users.dev = {
    isNormalUser = true;
    description = "Forge development user";
    uid = 1000;
    group = "users";
    extraGroups = [
      "docker"
      "tss"
      "wheel"
    ];
    home = "/srv/dev/home/dev";
    hashedPassword = "!";
    openssh.authorizedKeys.keys = [ publicKeys.ssh.roelc ];
  };

  services = {
    openssh = {
      hostKeys = [
        {
          path = sshHostKey;
          type = "ed25519";
        }
      ];
      settings = {
        # cmux uses a reverse SSH tunnel for its loopback-only remote relay.
        # Keep local forwarding disabled and retain GatewayPorts=no from the
        # server baseline so the relay cannot become a network listener.
        AllowAgentForwarding = false;
        AllowStreamLocalForwarding = false;
        AllowTcpForwarding = "remote";
        AllowUsers = [ "dev" ];
        DisableForwarding = lib.mkForce false;
        PermitTunnel = false;
      };
    };
    qemuGuest.enable = true;
    smartd.enable = lib.mkForce false;
  };

  security.tpm2 = {
    enable = true;
    tctiEnvironment.enable = true;
  };

  security.sudo = {
    wheelNeedsPassword = lib.mkForce true;
    extraRules = [
      {
        users = [ "dev" ];
        commands = [
          {
            command = "/run/current-system/sw/bin/forge-dev-initialize";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };

  nix.settings = {
    cores = 0;
    max-jobs = 6;
    substituters = [ "https://cache.decort.tech?priority=30" ];
    trusted-public-keys = [ publicKeys.nixCache.forge ];
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  virtualisation.docker = {
    enable = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
      flags = [ "--filter=until=336h" ];
    };
    daemon.settings."data-root" = "/srv/dev/docker";
  };
  systemd.services.docker.unitConfig.ConditionPathIsMountPoint = "/srv/dev";

  environment.systemPackages = with pkgs; [
    age
    bottom
    corepack_22
    devenv
    docker-compose
    fd
    gcc
    gh
    gnumake
    go_1_26
    initializeDisks
    kind
    kubectl
    kubernetes-helm
    nodejs_22
    openssl
    pkg-config
    python3
    sops
    tpm2-tools
    trivy
  ];

  time.timeZone = "Europe/Amsterdam";
  i18n.defaultLocale = "en_IE.UTF-8";
  system.stateVersion = "26.05";
}
