{ config, lib, ... }: {
  imports = [ ./git ];

  config = {
    dc-tec.development = {
      git.enable = lib.mkDefault true;
    };
  };
}
