{ lib, stdenvNoCC, fetchFromGitHub, zip }:

stdenvNoCC.mkDerivation {
  pname = "barracuda-resources";
  version = "2023-06-02";

  src = fetchFromGitHub {
    owner = "RealTimeLogic";
    repo = "BAS-Resources";
    rev = "e0bad7cf7dc8e96592e0712a5c442c2c52cf3e05";
    hash = "sha256-rWIztFJhKrv71Mpla+tslDKAoyc7yv7gl70x/AD6HK8=";
  };

  buildInputs = [ zip ];

  buildPhase = ''
    runHook preBuild

    ${zip}/bin/zip -D -q -u -r -9 mako.zip .

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    cp mako.zip $out

    runHook postInstall
  '';
}
