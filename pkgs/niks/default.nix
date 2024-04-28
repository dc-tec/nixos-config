{
  fetchFromGitHub,
  buildGoModule,
  ...
}:
buildGoModule {
  pname = "niks";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "dc-tec";
    repo = "niks-cli";
    rev = "main";
    sha256 = "sha256-rS99ZYBE6TtznKKRFjfzHI+pNzM8zXlcLvHUqfletz8=";
  };

  vendorHash = null;
}
