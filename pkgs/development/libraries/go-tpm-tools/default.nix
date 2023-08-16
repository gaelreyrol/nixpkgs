{ lib
, buildGoModule
, fetchFromGitHub
, protobuf
, openssl
}:

buildGoModule rec {
  pname = "go-tpm-tools";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "google";
    repo = "go-tpm-tools";
    rev = "v${version}";
    hash = "sha256-hREgwp1NSzWx1EK8M9I7g781Oo4NaemJ5FryEDgVDF8=";
  };

  vendorHash = "sha256-9c/whuLMPupiX02YdyjJ5EkBmSxEr8F2BJ2sYUqADKI=";

  nativeBuildInputs = [ protobuf ];

  buildInputs = [ openssl ];

  ldflags = [ "-s" "-w" ];
  
  CGO_ENABLED = 1;

  env.GOWORK = "off";

  #env.NIX_DEBUG = 7;

  subPackages = [ "..." "cmd/gotpm" ];
  excludedPackages = [ "cmd" ];

  checkFlags = [ "-skip TestNetworkFetchIssuingCertificate" ];

  meta = with lib; {
    description = "Go packages built on go-tpm providing a high-level API for using TPMs";
    homepage = "https://github.com/google/go-tpm-tools";
    changelog = "https://github.com/google/go-tpm-tools/releases/tag/v${version}";
    license = licenses.asl20;
    platforms = platforms.linux;
    maintainers = with maintainers; [ gaelreyrol ];
    mainProgrm = "gotpm";
  };
}
