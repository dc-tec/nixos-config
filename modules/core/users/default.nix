{config, ...}: {
  config = {
    users = {
      mutableUsers = false;
      users = {
        roelc = {
          isNormalUser = true;
          home = "/home/roelc";
          extraGroups = ["systemd-journal"];
          hashedPasswordFile = config.sops.secrets."users/roelc".path;
        };
        root.hashedPasswordFile = config.sops.secrets."users/root".path;
      };
    };
  };
}
