{
  lib,
  rustPlatform,
  fetchFromGitHub,
  testers,
  mago,
}:

rustPlatform.buildRustPackage rec {
  pname = "mago";
  version = "0.0.6";

  src = fetchFromGitHub {
    owner = "carthage-software";
    repo = "mago";
    rev = version;
    hash = "sha256-j/VE2SuqmrqyFlcVxOULm8WNf2XV2CqHrlCJSYzM1LQ=";
  };

  cargoHash = "sha256-Sywp7+XmORdYhZyZb3zI1OAglLLiEP2NlhrBih3i15E=";

  passthru = {
    tests.version = testers.testVersion {
      package = mago;
      command = "mago --version";
      version = "mago-cli ${version}";
    };
  };

  meta = {
    changelog = "https://github.com/carthage-software/mago/releases/tag/${version}";
    description = "Mago is a toolchain for PHP that aims to provide a set of tools to help developers write better code";
    homepage = "https://github.com/carthage-software/mago";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ gaelreyrol ];
    mainProgram = "mago";
  };
}
