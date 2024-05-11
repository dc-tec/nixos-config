{lib, ...}: {
  options.dc-tec.wsl = {
    enable = lib.mkEnableOption "enable WSL2";
  };

  config = {
    wsl = {
      enable = lib.mkDefault false;

      defaultUser = "roelc";

      wslConf = {
        users.default = "roelc";
      };

      tarball = {
        configPath = "/home/roelc/repos/nixos-config/modules/wsl/output";
      };
    };
  };
}
