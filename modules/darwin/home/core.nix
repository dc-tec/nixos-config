{pkgs, ...}: {
  home-manager.users.roelc = {
    home.packages = with pkgs; [
      tlrc
      jq
      yq
      fd
      openssl
      wget
      curl
      coreutils
      direnv
      dnsutils
    ];
  };
}

