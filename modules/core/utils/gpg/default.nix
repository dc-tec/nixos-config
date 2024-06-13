{
  config,
  lib,
  pkgs,
  ...
}: {
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

  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-gtk2;
    enableSSHSupport = true;
  };
}
