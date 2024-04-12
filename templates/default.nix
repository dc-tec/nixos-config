rec {
  neovim = {
    path = ./neovim;
    description =
      "A Neovim/Nixvim Configuration";
  };
  default = neovim;
}
