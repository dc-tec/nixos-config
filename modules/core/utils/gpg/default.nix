{
  config,
  lib,
  pkgs,
  ...
}: {
  config = {
    dc-tec.core.zfs = lib.mkMerge [
      (lib.mkIf config.dc-tec.core.persistence.enable {
        homeDataLinks = [
          {
            directory = ".gnupg";
            mode = "0700";
          }
        ];
      })
      (lib.mkIf (!config.dc-tec.core.persistence.enable) {})
    ];

    environment = {
      systemPackages = with pkgs; [
        gnupg
        pinentry-gtk2
      ];
    };

    home-manager.users.roelc = {
      services.gpg-agent = {
        enable = true;
        enableZshIntegration = true;
        enableSshSupport = true;
        pinentryPackage = pkgs.pinentry-gtk2;
        defaultCacheTtl = 46000;
        extraConfig = ''
          allow-preset-passphrase
        '';
      };
    };
  };
}
