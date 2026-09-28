{
  lib,
  modulesPath,
  pkgs,
  ...
}:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "usb_storage"
        "usbhid"
        "sd_mod"
      ];
      kernelModules = [ "virtio" ];
    };
    kernelModules = [
      "kvm-amd"
      "xt_socket"
      "vhost-net"
      "bridge"
      "br_netfilter"
    ];
    extraModulePackages = [ ];
    # Pin an LTS kernel that remains inside OpenZFS' supported window.
    kernelPackages = pkgs.linuxPackages_6_12;
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
      options = [ "umask=0077" ];
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

  swapDevices = [ { device = "/dev/disk/by-label/swap"; } ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  hardware = {
    cpu.amd.updateMicrocode = true;
    enableRedistributableFirmware = true;
  };
  services = {
    fstrim.enable = true;
  };
}
