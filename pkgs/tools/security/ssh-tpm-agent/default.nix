{ lib
, buildGoModule
, fetchFromGitHub
, nix-update-script
, testers
, ssh-tpm-agent
}:

buildGoModule rec {
  pname = "ssh-tpm-agent";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "Foxboron";
    repo = "ssh-tpm-agent";
    rev = "v${version}";
    hash = "sha256-Pn9Paph52DbBTGLjw4g8MO80yVSeOSWiiuh6fYpHPs4=";
  };

  vendorHash = "sha256-95NsZYl654y1xlY9/cYw2FhbIVxIR5dEoKozjc9I8/0=";

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${version}"
  ];

  # Tests requires ms-tpm-20-ref simulator
  doCheck = false;

  passthru = {
    updateScript = nix-update-script { };
    tests.version = testers.testVersion {
      inherit version;
      package = ssh-tpm-agent;
      command = "ssh-tpm-agent --version";
    };
  };

  meta = with lib; {
    description = "SSH-agent for TPMs";
    homepage = "https://github.com/Foxboron/ssh-tpm-agent";
    changelog = "https://github.com/Foxboron/ssh-tpm-agent/releases/tag/v${version}";
    license = licenses.mit;
    maintainers = with maintainers; [ gaelreyrol ];
  };
}
