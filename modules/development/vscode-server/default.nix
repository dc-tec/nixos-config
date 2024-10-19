{
  lib,
  config,
  ...
}: {
  options = {
    dc-tec.development = {
      vscode-server.enable = lib.mkEnableOption "VSCode Server";
    };
  };

  config = lib.mkIf config.dc-tec.development.vscode-server.enable {
    programs.nix-ld.enable = true;
    home-manager.users.roelc = {
      imports = [
        "${fetchTarball {
          url = "https://github.com/msteen/nixos-vscode-server/tarball/master";
          sha256 = "1rq8mrlmbzpcbv9ys0x88alw30ks70jlmvnfr2j8v830yy5wvw7h";
        }}/modules/vscode-server/home.nix"
      ];

      services.vscode-server.enable = true;
    };
  };
}
