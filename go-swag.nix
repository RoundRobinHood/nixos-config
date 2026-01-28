{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:

buildGoModule rec {
  pname = "go-swag";
  version = "2";

  src = fetchFromGitHub {
    owner = "swaggo";
    repo = "swag";
    rev = "v${version}";
    sha256 = "sha256-Qo+dU1n+FYa97s2HXgROQtQJYjVSBflVnYT8512Y0xE=";
  };

  subPackages = [ "cmd/swag" ];

  vendorHash = "sha256-s4DdnXGPhML80gWVRVqLhKdPZxoguWOI2tjYOTOJzlk=";

  meta = {
    description = "Automatically generate RESTful API documentation with Swagger 2.0 for Go";
    homepage = "https://github.com/swaggo/swag";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ stephenwithph ];
    mainProgram = "swag";
  };
}
