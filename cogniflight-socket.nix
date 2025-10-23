{ 
  fetchFromGitHub,
  lib,
  buildGoModule,
}:

buildGoModule {
  pname = "cogniflight-cloud";
  version = "0";

  src = fetchFromGitHub {
    owner = "RoundRobinHood";
    repo = "cogniflight-cloud";
    rev = "d80854ffe56b3249e7e95722cdde540e2eafe66d";
    sha256 = "sha256-S2vvS9oripvV+N3QJwm495nRn5IEwOTCAxmD9gT80wE=";
  };

  subPackages = [
    "tools/socket-client"
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp $GOPATH/bin/socket-client $out/bin/cogniflight-socket
  '';

  vendorHash = "sha256-+FoOfUGf2N5mvubrbmLnz4uiob1fPyOFRNTVc1jEgX8=";

  modRoot = "backend";

  meta = with lib; {
    description = "Socket CLI client for cogniflight-cloud websocket servers";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
