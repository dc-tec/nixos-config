{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {
    dc-tec.development.virtualisation = {
      hypervisor.enable = lib.mkEnableOption "Libvirt/KVM";
    };
  };

  config = lib.mkIf config.dc-tec.development.virtualisation.hypervisor.enable {
    dc-tec.core.zfs.systemCacheLinks = ["/var/lib/libvirt"];

    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        ovmf.enable = true;
        runAsRoot = false;
      };

      onBoot = "start";
      onShutdown = "shutdown";
    };

    home-manager.users.roelc = {
      home.packages = with pkgs; [
        virt-manager
      ];
    };

    users.users.roelc = {
      extraGroups = ["libvirtd"];
    };
  };
}
