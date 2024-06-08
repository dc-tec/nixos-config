{config, ...}: {
  dc-tec = {
    dataPrefix = "/data";
    core = {
      zfs = {
        ensureSystemExists = ["${config.dc-tec.dataPrefix}/etc/ssh"];
      };
    };
  };

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
}
