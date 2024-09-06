{pkgs, ...}: {
  home-manager.users.roelc = {
    home.packages = with pkgs; [
      tlrc
      fd
      openssl
      wget
      curl
      coreutils
      direnv
      dnsutils
      atac
    ];
  };
}
