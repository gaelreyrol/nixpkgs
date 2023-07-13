{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "ssokenizer";
  version = "unstable-2023-07-13";

  src = fetchFromGitHub {
    owner = "superfly";
    repo = "ssokenizer";
    rev = "b7e23984d98961e76b788e89639d720255d6c8bb";
    hash = "sha256-HMagH7vXEFzM+mEMJxO8F/NwMMh79kc3m++RRqkIksE=";
  };

  vendorHash = "sha256-t3KBP9AxCDgJlyoCjMRwRiWgpj30H4n5+t9GmFvQcLQ=";

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${version}"
    "-X main.Commit=unknown"
  ];

  subPackages = [ "cmd/ssokenizer" ];

  postInstall = ''
    install -D etc/ssokenizer.yml -t $out/etc/
  '';

  meta = with lib; {
    description = "OAuth delegation based on tokenizer";
    homepage = "https://github.com/superfly/ssokenizer";
    license = licenses.asl20;
    maintainers = with maintainers; [ gaelreyrol ];
    mainProgram = "ssokenizer";
  };
}
