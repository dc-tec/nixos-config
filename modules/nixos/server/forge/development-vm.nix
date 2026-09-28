{
  lib,
  pkgs,
  ...
}:
let
  vmName = "forge-dev";
  luksName = "forge-dev-durable";
  containerFile = "/var/lib/forge-vms/${vmName}.luks";
  durableRoot = "/var/lib/forge-vms/durable";
  vmRoot = "${durableRoot}/${vmName}";
  cacheRoot = "/cache/forge-vms/${vmName}";
  rootImage = "${vmRoot}/root.qcow2";
  dataImage = "${vmRoot}/data.qcow2";
  cacheImage = "${cacheRoot}/cache.qcow2";
  qemuPackage = pkgs.qemu_kvm.override {
    alsaSupport = false;
    fuseSupport = false;
    guestAgentSupport = false;
    gtkSupport = false;
    jackSupport = false;
    libiscsiSupport = false;
    ncursesSupport = false;
    openGLSupport = false;
    pipewireSupport = false;
    pulseSupport = false;
    sdlSupport = false;
    smartcardSupport = false;
    spiceSupport = false;
    tpmSupport = true;
    vncSupport = false;
  };

  domainXml = pkgs.writeText "${vmName}.xml" ''
    <domain type='kvm'>
      <name>${vmName}</name>
      <uuid>e23d51ea-cd50-42af-aa00-e27295316460</uuid>
      <memory unit='KiB'>20971520</memory>
      <currentMemory unit='KiB'>20971520</currentMemory>
      <vcpu placement='static'>6</vcpu>
      <os firmware='efi'>
        <type arch='x86_64' machine='q35'>hvm</type>
        <firmware>
          <feature enabled='no' name='secure-boot'/>
        </firmware>
      </os>
      <features>
        <acpi/>
        <apic/>
      </features>
      <cpu mode='host-passthrough' check='none' migratable='off'/>
      <clock offset='utc'/>
      <on_poweroff>destroy</on_poweroff>
      <on_reboot>restart</on_reboot>
      <on_crash>restart</on_crash>
      <devices>
        <emulator>${lib.getExe qemuPackage}</emulator>
        <disk type='file' device='disk'>
          <driver name='qemu' type='qcow2' cache='none' discard='unmap'/>
          <source file='${rootImage}'/>
          <target dev='vda' bus='virtio'/>
          <serial>dev-root</serial>
        </disk>
        <disk type='file' device='disk'>
          <driver name='qemu' type='qcow2' cache='none' discard='unmap'/>
          <source file='${dataImage}'/>
          <target dev='vdb' bus='virtio'/>
          <serial>dev-data</serial>
        </disk>
        <disk type='file' device='disk'>
          <driver name='qemu' type='qcow2' cache='none' discard='unmap'/>
          <source file='${cacheImage}'/>
          <target dev='vdc' bus='virtio'/>
          <serial>dev-cache</serial>
        </disk>
        <interface type='bridge'>
          <mac address='52:54:00:77:00:10'/>
          <source bridge='br-dev'/>
          <model type='virtio'/>
        </interface>
        <serial type='pty'>
          <target type='isa-serial' port='0'/>
        </serial>
        <console type='pty'>
          <target type='serial' port='0'/>
        </console>
        <channel type='unix'>
          <target type='virtio' name='org.qemu.guest_agent.0'/>
        </channel>
        <tpm model='tpm-crb'>
          <backend type='emulator' version='2.0' persistent_state='yes'>
            <source type='dir' path='${vmRoot}/tpm'/>
          </backend>
        </tpm>
        <memballoon model='virtio'/>
      </devices>
    </domain>
  '';

  vmStart = pkgs.writeShellApplication {
    name = "forge-dev-vm-start";
    runtimeInputs = [ pkgs.libvirt ];
    text = ''
      state="$(virsh --connect qemu:///system domstate ${vmName} 2>/dev/null || true)"
      case "$state" in
        running | paused) ;;
        *) virsh --connect qemu:///system start ${vmName} ;;
      esac
    '';
  };

  vmStop = pkgs.writeShellApplication {
    name = "forge-dev-vm-stop";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.libvirt
    ];
    text = ''
      state="$(virsh --connect qemu:///system domstate ${vmName} 2>/dev/null || true)"
      case "$state" in
        running | paused)
          virsh --connect qemu:///system shutdown ${vmName}
          ;;
        *) exit 0 ;;
      esac

      for _ in $(seq 1 90); do
        state="$(virsh --connect qemu:///system domstate ${vmName} 2>/dev/null || true)"
        case "$state" in
          running | paused | "in shutdown") sleep 1 ;;
          *) exit 0 ;;
        esac
      done

      echo "${vmName} did not shut down within 90 seconds; refusing to detach its storage" >&2
      exit 1
    '';
  };

  storageInitialize = pkgs.writeShellApplication {
    name = "forge-dev-storage-initialize";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.cryptsetup
      pkgs.e2fsprogs
      pkgs.util-linux
    ];
    text = ''
      if (( EUID != 0 )); then
        echo "forge-dev-storage-initialize must run as root" >&2
        exit 1
      fi
      if [[ -e ${containerFile} ]]; then
        echo "${containerFile} already exists; refusing to overwrite it" >&2
        exit 1
      fi

      printf 'Type INITIALIZE forge-dev-storage to create the 150 GiB encrypted container: '
      read -r confirmation
      if [[ "$confirmation" != "INITIALIZE forge-dev-storage" ]]; then
        echo "initialization cancelled" >&2
        exit 1
      fi

      umask 0077
      install -d -m 0000 -o root -g root ${durableRoot}
      truncate --size 150G ${containerFile}
      cryptsetup luksFormat --type luks2 ${containerFile}
      cryptsetup open ${containerFile} ${luksName}
      mkfs.ext4 -L forge-dev-durable /dev/mapper/${luksName}
      mount ${durableRoot}
      install -d -m 0750 -o root -g qemu-libvirtd ${durableRoot}
      install -d -m 0750 -o qemu-libvirtd -g qemu-libvirtd ${vmRoot}

      echo "encrypted Forge development storage is initialized and mounted"
    '';
  };

  storageUnlock = pkgs.writeShellApplication {
    name = "forge-dev-storage-unlock";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.cryptsetup
      pkgs.libvirt
      pkgs.systemd
      pkgs.util-linux
    ];
    text = ''
      if (( EUID != 0 )); then
        echo "forge-dev-storage-unlock must run as root" >&2
        exit 1
      fi
      if ! cryptsetup isLuks ${containerFile}; then
        echo "${containerFile} is not an initialized LUKS container" >&2
        exit 1
      fi

      if [[ ! -e /dev/mapper/${luksName} ]]; then
        cryptsetup open ${containerFile} ${luksName}
      fi
      if ! mountpoint --quiet ${durableRoot}; then
        mount ${durableRoot}
      fi
      install -d -m 0750 -o root -g qemu-libvirtd ${durableRoot}

      if virsh --connect qemu:///system dominfo ${vmName} >/dev/null 2>&1; then
        systemctl start forge-dev-vm.service
      else
        echo "storage unlocked; run forge-dev-vm-bootstrap after building the guest image"
      fi
    '';
  };

  storageLock = pkgs.writeShellApplication {
    name = "forge-dev-storage-lock";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.cryptsetup
      pkgs.systemd
      pkgs.util-linux
    ];
    text = ''
      if (( EUID != 0 )); then
        echo "forge-dev-storage-lock must run as root" >&2
        exit 1
      fi

      systemctl stop forge-dev-vm.service
      if mountpoint --quiet ${durableRoot}; then
        umount ${durableRoot}
      fi
      chmod 0000 ${durableRoot}
      if [[ -e /dev/mapper/${luksName} ]]; then
        cryptsetup close ${luksName}
      fi
    '';
  };

  vmBootstrap = pkgs.writeShellApplication {
    name = "forge-dev-vm-bootstrap";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.findutils
      pkgs.libvirt
      pkgs.qemu-utils
      pkgs.systemd
      pkgs.util-linux
    ];
    text = ''
      if (( EUID != 0 )); then
        echo "forge-dev-vm-bootstrap must run as root" >&2
        exit 1
      fi
      if ! mountpoint --quiet ${durableRoot}; then
        echo "${durableRoot} is not mounted; unlock the encrypted storage first" >&2
        exit 1
      fi
      if ! mountpoint --quiet /cache; then
        echo "/cache is not mounted; refusing to place a cache disk on the root filesystem" >&2
        exit 1
      fi

      install -d -m 0750 -o qemu-libvirtd -g qemu-libvirtd \
        ${vmRoot} \
        ${vmRoot}/tpm

      source_path="''${1:-}"
      if [[ ! -e ${rootImage} ]]; then
        if [[ -z "$source_path" ]]; then
          echo "usage: forge-dev-vm-bootstrap QEMU_EFI_IMAGE_OR_DIRECTORY" >&2
          exit 2
        fi
        if [[ -d "$source_path" ]]; then
          mapfile -t candidates < <(find "$source_path" -maxdepth 2 -type f -name '*.qcow2')
          if [[ "''${#candidates[@]}" -ne 1 ]]; then
            echo "expected exactly one qcow2 image below $source_path" >&2
            exit 1
          fi
          source_path="''${candidates[0]}"
        fi
        if [[ ! -f "$source_path" ]]; then
          echo "guest root image does not exist: $source_path" >&2
          exit 1
        fi

        cp --reflink=auto --sparse=always "$source_path" ${rootImage}
        qemu-img resize ${rootImage} 32G
      fi

      install -d -m 0750 -o qemu-libvirtd -g qemu-libvirtd ${cacheRoot}
      if [[ ! -e ${dataImage} ]]; then
        qemu-img create -f qcow2 ${dataImage} 100G
      fi
      if [[ ! -e ${cacheImage} ]]; then
        qemu-img create -f qcow2 ${cacheImage} 120G
      fi
      chown qemu-libvirtd:qemu-libvirtd ${rootImage} ${dataImage} ${cacheImage}
      chmod 0640 ${rootImage} ${dataImage} ${cacheImage}

      virsh --connect qemu:///system define ${domainXml}
      virsh --connect qemu:///system autostart --disable ${vmName} >/dev/null
      systemctl start forge-dev-vm.service
    '';
  };
in
{
  networking = {
    bridges.br-dev.interfaces = [ ];
    interfaces.br-dev.ipv4.addresses = [
      {
        address = "10.78.0.1";
        prefixLength = 24;
      }
    ];
    nat = {
      enable = true;
      externalInterface = "enp1s0f0";
      internalInterfaces = [ "br-dev" ];
    };
    firewall.interfaces.wg0.allowedTCPPorts = [ 2222 ];
  };

  virtualisation.libvirtd = {
    enable = true;
    allowedBridges = [ "br-dev" ];
    onBoot = "ignore";
    onShutdown = "shutdown";
    qemu = {
      package = qemuPackage;
      runAsRoot = false;
      swtpm.enable = true;
    };
  };

  fileSystems.${durableRoot} = {
    device = "/dev/mapper/${luksName}";
    fsType = "ext4";
    options = [
      "noauto"
      "nofail"
    ];
  };

  environment.systemPackages = [
    pkgs.cryptsetup
    storageInitialize
    storageLock
    storageUnlock
    vmBootstrap
  ];

  systemd = {
    services = {
      forge-dev-vm = {
        description = "Forge development virtual machine";
        after = [ "libvirtd.service" ];
        requires = [ "libvirtd.service" ];
        unitConfig = {
          ConditionPathExists = "/var/lib/libvirt/qemu/${vmName}.xml";
          RequiresMountsFor = durableRoot;
        };
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = lib.getExe vmStart;
          ExecStop = lib.getExe vmStop;
          TimeoutStopSec = 100;
        };
      };

      forge-dev-ssh-proxy = {
        description = "Proxy WireGuard SSH traffic to forge-dev";
        requires = [ "forge-dev-ssh-proxy.socket" ];
        after = [ "network.target" ];
        serviceConfig = {
          ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd 10.78.0.10:22";
          DynamicUser = true;
          NoNewPrivileges = true;
          PrivateTmp = true;
          ProtectHome = true;
          ProtectSystem = "strict";
        };
      };
    };

    sockets.forge-dev-ssh-proxy = {
      description = "Forge development VM SSH proxy";
      wantedBy = [ "sockets.target" ];
      listenStreams = [ "10.77.0.1:2222" ];
      socketConfig.FreeBind = true;
    };

    tmpfiles.rules = [
      "d /var/lib/forge-vms 0710 root qemu-libvirtd -"
      "d /cache/forge-vms 0750 qemu-libvirtd qemu-libvirtd -"
    ];
  };
}
