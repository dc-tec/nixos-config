{
  buildGoModule,
  inputs,
  ...
}:
buildGoModule {
  pname = "niks";
  version = inputs.niks-cli.shortRev or "unstable";
  src = inputs.niks-cli;

  vendorHash = null;
}
