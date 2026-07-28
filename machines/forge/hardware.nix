{
  config,
  lib,
  pkgs,
  ...
}:
{
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  assertions = [
    {
      assertion = lib.versionAtLeast config.boot.kernelPackages.kernel.version "6.19";
      message = ''
        forge requires Linux 6.19 or newer because the nixos-anywhere installer
        records the mdraid logical block size introduced by Linux 6.19.
      '';
    }
  ];

  boot = {
    # Keep the installed kernel compatible with mdraid arrays created by the
    # current nixos-anywhere kexec image.
    kernelPackages = pkgs.linuxPackages_latest;

    initrd = {
      availableKernelModules = [
        "ahci"
        "sd_mod"
        "usb_storage"
        "usbhid"
        "xhci_pci"
      ];
      kernelModules = [ "raid1" ];
    };
    kernelModules = [ "kvm-intel" ];

    loader.grub.enable = true;

    swraid = {
      enable = true;
      # Replace local root mail with external alerting in the monitoring slice.
      mdadmConf = "MAILADDR root";
    };
  };

  hardware = {
    cpu.intel.updateMicrocode = true;
    enableRedistributableFirmware = true;
  };
}
