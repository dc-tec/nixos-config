{
  lib,
  config,
  pkgs,
  ...
}:
{
  config = {
    # System Wide Packages
    environment.systemPackages = with pkgs; [
      wget
      curl
      coreutils
      unzip
      openssl
      dnsutils
      nmap
      lshw
      util-linux
      whois
      moreutils
      git
      age
      sops
      ssh-to-age
      tcpdump
      bridge-utils
    ];

    # User Packages
    home-manager.users.${config.dc-tec.user.name} = {
      home = {
        packages = with pkgs; [
          tlrc
          fontconfig
          fd
          jq
          yq
          direnv
          atac
          comma
          autojump
          ollama
        ];
      };
    };
  };
}
