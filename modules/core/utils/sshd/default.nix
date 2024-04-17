 { config, lib, ... }: {
 
  dc-tec.core.zfs = {
   ensureSystemExists = [ "${config.dc-tec.dataPrefix}/etc/ssh" ];
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
        path = "${config.dc-tec.dataPrefix}/etc/ssh/ssh_host_rsa_key";
        type = "rsa";
      }
      {
        bits = 4096;
        path = "${config.dc-tec.dataPrefix}/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
   };

   age.secrets."authorized_keys/root" = {
     file = ../../../../secrets/authorized_keys/root.age;
     path = "/root/.ssh/authorized_keys";
     symlink = false;
   };

   age.secrets."authorized_keys/roelc" = {
     file = ../../../../secrets/authorized_keys/roelc.age;
     owner = "roelc";
     path = "/home/roelc/.ssh/authorized_keys";
     symlink = false;
   };
}
