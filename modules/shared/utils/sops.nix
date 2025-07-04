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
      
      # Only use SSH keys on Linux systems, Darwin relies solely on age keys
      sshKeyPaths = lib.optionals config.dc-tec.isLinux [
        (if config.dc-tec.persistence.enable then
          "${config.dc-tec.persistence.dataPrefix}/etc/ssh/ssh_host_ed25519_key"
        else
          "/etc/ssh/ssh_host_ed25519_key")
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

        # GPG keys for Linux
        "gpg/private_key" = {
          path = "${config.dc-tec.user.homeDirectory}/.gnupg/private-key.asc";
          owner = config.dc-tec.user.name;
          mode = "0600";
        };

        "gpg/public_key" = {
          path = "${config.dc-tec.user.homeDirectory}/.gnupg/public-key.asc";
          owner = config.dc-tec.user.name;
          mode = "0644";
        };

        "gpg/trust_db" = {
          path = "${config.dc-tec.user.homeDirectory}/.gnupg/trust-db.txt";
          owner = config.dc-tec.user.name;
          mode = "0600";
        };
      })
      
      # Darwin-specific secrets
      (lib.mkIf config.dc-tec.isDarwin {
        "authorized_keys/roelc" = {
          path = "${config.dc-tec.user.homeDirectory}/.ssh/authorized_keys";
          owner = config.dc-tec.user.name;
        };

        # GPG keys for Darwin
        "gpg/private_key" = {
          path = "${config.dc-tec.user.homeDirectory}/.gnupg/private-key.asc";
          owner = config.dc-tec.user.name;
          mode = "0600";
        };

        "gpg/public_key" = {
          path = "${config.dc-tec.user.homeDirectory}/.gnupg/public-key.asc";
          owner = config.dc-tec.user.name;
          mode = "0644";
        };

        "gpg/trust_db" = {
          path = "${config.dc-tec.user.homeDirectory}/.gnupg/trust-db.txt";
          owner = config.dc-tec.user.name;
          mode = "0600";
        };
      })
    ];
  };
}
