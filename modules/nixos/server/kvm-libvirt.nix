_: {
  # Bridge setup and VM helper scripts also reference pkgs.libvirt directly.
  nixpkgs.overlays = [
    (_: prev: {
      libvirt = prev.libvirt.override { enableXen = false; };
    })
  ];
}
