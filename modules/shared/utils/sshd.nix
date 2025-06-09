{
  config,
  lib,
  ...
}: {
  options.dc-tec.services.sshd = {
    enable = lib.mkEnableOption "OpenSSH daemon";
  };

  config = lib.mkIf (config.dc-tec.isLinux && config.dc-tec.services.sshd.enable) {
    dc-tec.core.zfs = lib.mkMerge [
      (lib.mkIf config.dc-tec.core.persistence.enable {
        ensureSystemExists = ["${config.dc-tec.dataPrefix}/etc/ssh"];
      })
      (lib.mkIf (!config.dc-tec.core.persistence.enable) {})
    ];

    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "prohibit-password";

        # Remove stale sockets
        StreamLocalBindUnlink = "yes";
      };

      hostKeys = [
        {
          bits = 4096;
          path =
            if config.dc-tec.core.persistence.enable
            then "${config.dc-tec.dataPrefix}/etc/ssh/ssh_host_rsa_key"
            else "/etc/ssh/ssh_host_rsa_key";
          type = "rsa";
        }
        {
          bits = 4096;
          path =
            if config.dc-tec.core.persistence.enable
            then "${config.dc-tec.dataPrefix}/etc/ssh/ssh_host_ed25519_key"
            else "/etc/ssh/ssh_host_ed25519";
          type = "ed25519";
        }
      ];
    };
  };
}
