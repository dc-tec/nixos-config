{
  lib,
  config,
  pkgs,
  ...
}:
{
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

    dc-tec.colorScheme.flavor = lib.mkOption {
      type = lib.types.str;
      description = "Default flavor for the color scheme.";
      default = "macchiato";
    };

    dc-tec.colorScheme.accent = lib.mkOption {
      type = lib.types.str;
      description = "Default accent for the color scheme.";
      default = "peach";
    };

    # System version option
    dc-tec.stateVersion = lib.mkOption {
      type = lib.types.str;
      example = "23.11";
      description = "NixOS state version";
    };

    dc-tec.timeZone = lib.mkOption {
      type = lib.types.str;
      default = "Europe/Amsterdam";
      description = "Time zone for the system.";
    };

    # Impermanence options
    dc-tec.persistence = {
      enable = lib.mkEnableOption "Enable persistence/impermanence";
      
      dataPrefix = lib.mkOption {
        type = lib.types.str;
        default = "/data";
        description = "Prefix for persistent data storage";
      };
      
      cachePrefix = lib.mkOption {
        type = lib.types.str;
        default = "/cache";
        description = "Prefix for persistent cache storage";
      };
    };

    # Stub for core namespace so that shared modules referencing
    # `dc-tec.core.*` options are accepted when running on platforms
    # that do not import the Linux-specific ZFS module.
    dc-tec.core = lib.mkOption {
      type = lib.types.submodule {};
      default = {};
      description = "Namespace for Linux-only core settings. Empty on Darwin.";
    };
  };

  config = {
    dc-tec.isLinux = lib.dc-tec.isLinux;
    dc-tec.isDarwin = lib.dc-tec.isDarwin;
    dc-tec.font = if lib.dc-tec.isDarwin then "0xProto" else "0xProto Nerd Font";
    
    # Enable persistence by default only on Linux systems
    # This can be overridden per-machine as needed
    dc-tec.persistence.enable = lib.mkDefault config.dc-tec.isLinux;
  };
}

