{
  lib,
  config,
  ...
}: {
  options = {
    dc-tec.development.k8s = {
      k9s.enable = lib.mkEnableOption "k9s";
    };
  };

  config = lib.mkIf config.dc-tec.development.k8s.k9s.enable {
    home-manager.users.roelc = {
      programs.k9s = {
        enable = true;
        catppuccin = {
          enable = true;
          flavour = "macchiato";
          #transparant = true;
        };
      };
    };
  };
}
