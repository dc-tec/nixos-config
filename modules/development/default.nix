{lib, ...}: {
  imports = [
    ./git
    ./python
    ./ansible
    ./aws-cli
    ./azure-cli
    ./go
    ./terraform
    ./packer
    ./powershell
    ./virtualisation
  ];

  config = {
    dc-tec.development = {
      git.enable = lib.mkDefault true;
      ansible.enable = lib.mkDefault true;
      aws-cli.enable = lib.mkDefault true;
      azure-cli.enable = lib.mkDefault true;
      go.enable = lib.mkDefault true;
      terraform.enable = lib.mkDefault true;
      packer.enable = lib.mkDefault true;
      powershell.enable = lib.mkDefault true;
      python312.enable = lib.mkDefault true;
      virtualisation = {
        docker.enable = lib.mkDefault false;
        k8s.enable = lib.mkDefault false;
        hypervisor.enable = lib.mkDefault false;
      };
    };
  };
}
