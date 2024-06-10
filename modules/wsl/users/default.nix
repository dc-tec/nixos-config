_: {
  users = {
    mutableUsers = true;
    users = {
      roelc = {
        isNormalUser = true;
        home = "/home/roelc";
        extraGroups = ["systemd-journal"];
      };
    };
  };
}
