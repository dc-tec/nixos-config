{
  modulesPath,
  publicKeys,
  ...
}:
{
  imports = [
    (modulesPath + "/profiles/minimal.nix")
    ../../modules/nixos/server/forge
    ./disko.nix
    ./hardware.nix
    ./wireguard.nix
  ];

  networking = {
    hostName = "forge";
    useDHCP = false;
    interfaces.enp1s0f0.useDHCP = true;
  };
  services.openssh.settings.AllowUsers = [
    "git"
    "roelc@10.77.0.2"
  ];

  users.users.roelc = {
    isNormalUser = true;
    description = "Roel de Cort";
    extraGroups = [ "wheel" ];
    hashedPassword = "!";
    openssh.authorizedKeys.keys = [ publicKeys.ssh.roelc ];
  };

  time.timeZone = "Europe/Amsterdam";
  i18n.defaultLocale = "en_IE.UTF-8";

  system.stateVersion = "26.05";
}
