{
  config,
  lib,
  modulesPath,
  ...
}: {
  imports = [(modulesPath + "/installer/scan/not-detected.nix")];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    initrd = {
      availableKernelModules = ["xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod"];
      kernelModules = ["virtio"];
    };
    kernelParams = ["mitigations=off"];
    kernelModules = [
      "kvm-amd"
      "xt_socket"
      "vhost-net"
      "bridge"
      "br_netfilter"
    ];
    extraModulePackages = [];
    kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
    kernel = {
      sysctl."net.ipv4.ip_forward" = 1;
    };
  };

  fileSystems = {
    "/" = {
      device = "rpool/local/root";
      fsType = "zfs";
      neededForBoot = true;
    };
    "/boot" = {
      device = "/dev/disk/by-label/EFI";
      fsType = "vfat";
    };
    "/nix" = {
      device = "rpool/local/nix";
      fsType = "zfs";
      neededForBoot = true;
    };
    "/nix/store" = {
      device = "rpool/local/nix-store";
      fsType = "zfs";
      neededForBoot = true;
    };
    "/cache" = {
      device = "rpool/local/cache";
      fsType = "zfs";
      neededForBoot = true;
    };
    "/data" = {
      device = "rpool/safe/data";
      fsType = "zfs";
      neededForBoot = true;
    };
  };

  swapDevices = [{device = "/dev/disk/by-label/swap";}];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  hardware = {
    cpu.amd.updateMicrocode = true;
    enableRedistributableFirmware = true;
    graphics.enable = true;
    nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.latest;
      powerManagement.enable = true;
      open = false;
      modesetting = {
        enable = true;
      };
    };
  };
  services = {
    fstrim.enable = true;
    blueman.enable = true;
  };

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "nvidia-x11"
      "nvidia"
      "nvidia-settings"
    ];
}
