{lib, ...}: {
  imports = [
    ./git
    ./python
    ./ansible
    ./aws-cli
    ./azure-cli
    ./go
    ./terraform
    ./powershell
  ];

  config = {
    dc-tec.development = {
      git.enable = lib.mkDefault true;
      python.enable = lib.mkDefault true;
      ansible.enable = lib.mkDefault true;
      aws-cli.enable = lib.mkDefault true;
      azure-cli.enable = lib.mkDefault true;
      go.enable = lib.mkDefault true;
      terraform.enable = lib.mkDefault true;
      powershell.enable = lib.mkDefault true;
    };
  };
}
