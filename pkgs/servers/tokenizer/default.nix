{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "tokenizer";
  version = "unstable-2023-07-13";

  src = fetchFromGitHub {
    owner = "superfly";
    repo = "tokenizer";
    rev = "fe18ba07feecf4a29e27f14a0f2f53cd168b0b4d";
    hash = "sha256-ez1TKErdj92/1abuqw9aeQGrea70E9qaLOqcoo3KDYY=";
  };

  vendorHash = "sha256-vIpSTE8rZ9+PtN+WgVSoBokRqiZX5fySmsMLJVK9S5Y=";

  filteredHeaders = [
    "Fly-Client-Ip"
    "Fly-Forwarded-Port"
    "Fly-Forwarded-Proto"
    "Fly-Forwarded-Ssl"
    "Fly-Region"
    "Fly-Request-Id"
    "Fly-Traceparent"
    "Fly-Tracestate"
  ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/superfly/tokenizer/cmd/tokenizer.FilteredHeaders=${builtins.concatStringsSep "," filteredHeaders}"
  ];

  subPackages = [ "cmd/tokenizer" ];

  meta = with lib; {
    description = "HTTP proxy that injects 3rd part credentials into requests";
    homepage = "https://github.com/superfly/tokenizer";
    license = licenses.asl20;
    maintainers = with maintainers; [ gaelreyrol ];
    mainProgram = "tokenizer";
  };
}
