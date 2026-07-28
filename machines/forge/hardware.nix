{ lib, ... }:
{
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  boot = {
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
