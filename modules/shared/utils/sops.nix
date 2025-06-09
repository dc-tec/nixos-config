{
  config,
  lib,
  ...
}: {
  sops = {
    defaultSopsFile = ../../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";

    age = {
      keyFile = 
        if config.dc-tec.isDarwin then
          "/Users/${config.dc-tec.user.name}/.config/sops/age/keys.txt"
        else
          "/home/${config.dc-tec.user.name}/.config/sops/age/keys.txt";
      
      sshKeyPaths = lib.optionals config.dc-tec.isLinux [
        (if config.dc-tec.persistence.enable then
          "${config.dc-tec.persistence.dataPrefix}/etc/ssh/ssh_host_ed25519_key"
        else
          "/etc/ssh/ssh_host_ed25519_key")
      ] ++ lib.optionals config.dc-tec.isDarwin [
        "/etc/ssh/ssh_host_ed25519_key"
      ];
      
      generateKey = true;
    };

    secrets = lib.mkMerge [
      # Linux-specific secrets
      (lib.mkIf config.dc-tec.isLinux {
        "users/roelc" = {
          neededForUsers = true;
        };

        "users/root" = {
          neededForUsers = true;
        };

        wireless = {};

        "authorized_keys/root" = {
          path = "/root/.ssh/authorized_keys";
        };

        "authorized_keys/roelc" = {
          path = "${config.dc-tec.user.homeDirectory}/.ssh/authorized_keys";
          owner = config.dc-tec.user.name;
        };
      })
      
      # Darwin-specific secrets (if any)
      (lib.mkIf config.dc-tec.isDarwin {
        "authorized_keys/roelc" = {
          path = "${config.dc-tec.user.homeDirectory}/.ssh/authorized_keys";
          owner = config.dc-tec.user.name;
        };
        
        # Add other macOS-specific secrets here
      })
    ];
  };
}
