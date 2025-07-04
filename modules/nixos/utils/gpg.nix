{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.dc-tec.gpg.enable {
    # Enable GPG agent as a system service
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    # Ensure GPG directories exist at boot
    systemd.tmpfiles.rules = [
      "d /home/${config.dc-tec.user.name}/.gnupg 0700 ${config.dc-tec.user.name} ${config.dc-tec.user.name}"
    ];
  };
} 