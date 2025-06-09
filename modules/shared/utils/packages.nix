{config, pkgs, ...}: {
  home-manager.users.${config.dc-tec.user.name} = {
    home = {
      packages = with pkgs; [
        tlrc
        fd
        openssl
        wget
        curl
        coreutils
        direnv
        dnsutils
        atac
        just
        comma
        autojump
      ];
    };
  };
}
