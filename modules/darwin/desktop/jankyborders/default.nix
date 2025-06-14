{...}: {
  home-manager.users.roelc = {
    home.file."./.config/borders" = {
      source = ./.;
      recursive = true;
    };
  };
}
