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
        swtpm.enable = true;
        #        ovmf = {
        #          enable = true;
        #          packages = [
        #            (pkgs.OVMF.override {
        #              secureBoot = true;
        #              tpmSupport = true;
        #            })
        #           .fd
        #          ];
        #        };
        verbatimConfig = ''
          nvram = [ "/run/libvirt/nix-ovmf/AAVMF_CODE.fd:/run/libvirt/nix-ovmf/AAVMF_VARS.fd", "/run/libvirt/nix-ovmf/OVMF_CODE.fd:/run/libvirt/nix-ovmf/OVMF_VARS.fd" ]
        '';
        runAsRoot = true;
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
