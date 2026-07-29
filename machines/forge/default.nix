{ modulesPath, ... }:
{
  imports = [
    (modulesPath + "/profiles/minimal.nix")
    ./backup.nix
    ./alerting.nix
    ./cache.nix
    ./disko.nix
    ./hardware.nix
    ./monitoring.nix
    ./wireguard.nix
  ];

  networking = {
    hostName = "forge";
    useDHCP = false;
    interfaces.enp1s0f0.useDHCP = true;
  };
  services.openssh.settings.AllowUsers = [ "roelc" ];

  users.users.roelc = {
    isNormalUser = true;
    description = "Roel de Cort";
    extraGroups = [ "wheel" ];
    hashedPassword = "!";
    openssh.authorizedKeys.keyFiles = [ ../../keys/roelc.pub ];
  };

  time.timeZone = "Europe/Amsterdam";
  i18n.defaultLocale = "en_IE.UTF-8";

  system.stateVersion = "26.05";
}
