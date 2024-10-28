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
          sha256 = "09j4kvsxw1d5dvnhbsgih0icbrxqv90nzf0b589rb5z6gnzwjnqf";
        }}/modules/vscode-server/home.nix"
      ];

      services.vscode-server.enable = true;
    };
  };
}
