{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "cronsun";
  version = "0.3.5";

  src = fetchFromGitHub {
    owner = "shunfei";
    repo = "cronsun";
    rev = "v${version}";
    hash = "sha256-bB9uGPSHcLWu7U0WQJrn1Pyg7VHfpSVB0eixN7GraJY=";
  };

  vendorHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

  ldflags = [ "-s" "-w" ];

  meta = with lib; {
    description = "A Distributed, Fault-Tolerant Cron-Style Job System";
    homepage = "https://github.com/shunfei/cronsun";
    changelog = "https://github.com/shunfei/cronsun/releases/tag/v${version}";
    license = licenses.asl20;
    maintainers = with maintainers; [ gaelreyrol ];
  };
}
