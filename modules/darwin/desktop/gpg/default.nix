{...}: {
  home-manager.users.roelc = {
    home.file."./.gnupg" = {
      source = ./.;
      recursive = true;
    };
  };
}
