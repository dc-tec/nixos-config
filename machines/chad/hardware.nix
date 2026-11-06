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
    extraModprobeConfig = "options zfs zfs_arc_max=4294967296";
    # Pin an LTS kernel that remains inside OpenZFS' supported window.
    kernelPackages = pkgs.linuxPackages_6_12;
    kernel = {
      sysctl."net.ipv4.ip_forward" = 1;
    };
  };

  fileSystems."/".neededForBoot = true;
  fileSystems."/nix".neededForBoot = true;
  fileSystems."/nix/store".neededForBoot = true;
  fileSystems."/cache".neededForBoot = true;
  fileSystems."/cache/var/lib/libvirt".neededForBoot = true;
  fileSystems."/data".neededForBoot = true;
  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  hardware = {
    cpu.amd.updateMicrocode = true;
    enableRedistributableFirmware = true;
  };
  services = {
    fstrim.enable = true;
  };
}
