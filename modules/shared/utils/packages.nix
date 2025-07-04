{
  lib,
  config,
  pkgs,
  inputs,
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
      util-linux
      whois
      moreutils
      git
      age
      sops
      ssh-to-age
      tcpdump
      nvd
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
          inputs.nixvim.packages.${pkgs.system}.default
          claude-code
          bitwarden-cli
          bitwarden-desktop
        ];
      };
    };
  };
}
