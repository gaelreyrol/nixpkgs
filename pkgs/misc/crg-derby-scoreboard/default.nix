{ lib
, stdenv
, fetchFromGitHub
, openjdk
}:

stdenv.mkDerivation rec {
  pname = "crg-derby-scoreboard";
  version = "2023.2";

  src = fetchFromGitHub {
    owner = "rollerderby";
    repo = "scoreboard";
    rev = "v${version}";
    hash = "sha256-MFEBScTNxQGoFYY/RmW67kgDN3gZeAGnm5okcqaJ4xQ=";
  };

  nativeBuildInputs = [ openjdk ];

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -a * $out

    runHook postInstall
  '';

  meta = with lib; {
    description = "CRG Derby Scoreboard";
    homepage = "https://github.com/rollerderby/scoreboard";
    license = licenses.asl20;
    platforms = platforms.linux;
    maintainers = with maintainers; [ gaelreyrol ];
  };
}
