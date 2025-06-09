{
  lib,
  config,
  ...
}: {
  options = {
    dc-tec.isLinux = lib.mkOption {
      type = lib.types.bool;
      readOnly = true;
      description = "Whether the host is a Linux system.";
    };

    dc-tec.isDarwin = lib.mkOption {
      type = lib.types.bool;
      readOnly = true;
      description = "Whether the host is a Darwin system.";
    };

    dc-tec.font = lib.mkOption {
      type = lib.types.str;
      description = "Default font for the system.";
    };
  };

  config = {
    dc-tec.isLinux = lib.dc-tec.isLinux;
    dc-tec.isDarwin = lib.dc-tec.isDarwin;
    dc-tec.font = if lib.dc-tec.isDarwin then "0xProto" else "0xProto Nerd Font";
  };
} 