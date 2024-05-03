_: {
  sops = {
    defaultSopsFile = ../../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";

    age = {
      keyFile = "/home/roelc/.config/sops/age/keys.txt";
      sshKeyPaths = [
        "/data/etc/ssh/ssh_host_ed25519_key"
      ];
      generateKey = true;
    };

    secrets.roelc = {
      neededForUsers = true;
    };
    secrets.root = {
      neededForUsers = true;
    };
    secrets.unifi = {
      owner = "roelc";
    };
  };
}
