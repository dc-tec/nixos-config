{ config, lib, pkgs, nixvim, ... }: {

  imports = [
    ./settings
  ];

  let
    config = {
      home-manager.users.roelc = { pkgs,  ... }: {
        programs.nixvim = {
          enable = true;
        };
      };
    }; 
  in
  {
    programs.nixvim.enable = true;
  };
}
