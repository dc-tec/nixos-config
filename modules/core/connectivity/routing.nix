{
  config,
  lib,
  ...
}: {
  options.dc-tec.core.routing.enable = lib.mkEnableOption "network routing";

  config = lib.mkIf config.dc-tec.core.routing.enable {
    services.frr = {
      bgp = {
        enable = true;
      };
    };
  };
}
