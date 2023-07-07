{ lib
, buildGoModule
, fetchFromGitHub
, nix-update-script
, testers
, otel-trace
}:

buildGoModule rec {
  pname = "otel-trace";
  version = "0.0.12";

  src = fetchFromGitHub {
    owner = "Pondidum";
    repo = "Trace";
    rev = version;
    hash = "sha256-mhPEGCu9nikRetiTO0fUj2BkEX510CGbC2hn/mXyItQ=";
  };

  vendorHash = "sha256-unZMA1S9rYRlAitYmVIrNMTI1Cg0oevk2HWSoc6wLFs=";

  preBuild = "go generate ./...";

  ldflags = [
    "-s"
    "-w"
    # Requires raw commit hash because version is picked up from GitCommit[0:7] which produce an out of bounds slice range runtime error.
    "-X trace/version.GitCommit=\"1bb1b9a2f55337e8ecc567d13e905e1ed46267c2\""
    "-X trace/version.Prerelease=\"\""
  ];

  passthru = {
    updateScript = nix-update-script { };
    tests.version = testers.testVersion {
      inherit version;
      package = otel-trace;
      command = "trace version";
    };
  };

  meta = with lib; {
    description = "OTEL Tracing for your CI pipeline";
    homepage = "https://github.com/Pondidum/Trace/";
    changelog = "https://github.com/Pondidum/Trace/blob/${src.rev}/changelog.md";
    license = licenses.asl20;
    maintainers = with maintainers; [ gaelreyrol ];
    mainProgram = "trace";
  };
}
