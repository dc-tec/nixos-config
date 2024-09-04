{...}: {
  #services.sketchybar = {
  #  enable = true;
  #};

  home-manager.users.roelc = {
    home.file."./.config/sketchybar" = {
      source = ./.;
      recursive = true;
    };
  };
}
