{lib, ...}: {
  imports = [
    ./git
    ./python
    ./ansible
    ./aws-cli
    ./azure-cli
    ./go
    ./hashicorp
    ./powershell
    ./yaml
    ./virtualisation
    ./vscode-server
  ];

  config = {
    dc-tec.development = {
      git.enable = lib.mkDefault true;
      ansible.enable = lib.mkDefault true;
      aws-cli.enable = lib.mkDefault true;
      azure-cli.enable = lib.mkDefault true;
      go.enable = lib.mkDefault true;
      hashicorp.enable = lib.mkDefault true;
      powershell.enable = lib.mkDefault true;
      python312.enable = lib.mkDefault true;
      yamlls.enable = lib.mkDefault true;
      vscode-server.enable = lib.mkDefault false;
      virtualisation = {
        docker.enable = lib.mkDefault false;
        k8s.enable = lib.mkDefault false;
        hypervisor.enable = lib.mkDefault false;
      };
    };
  };
}
