{ stdenv
, lib
, fetchFromGitHub
, cmake
, pkg-config
, systemd
, runtimeShell
, python3
, nixosTests
}:

let
  version = "2.4.3";

  src = fetchFromGitHub {
    owner = "rvaiya";
    repo = "keyd";
    rev = "v" + version;
    hash = "sha256-NhZnFIdK0yHgFR+rJm4cW+uEhuQkOpCSLwlXNQy6jas=";
  };

  pypkgs = python3.pkgs;

  appMap = pypkgs.buildPythonApplication rec {
    pname = "keyd-application-mapper";
    inherit version src;
    format = "other";

    postPatch = ''
      substituteInPlace scripts/${pname} \
        --replace /bin/sh ${runtimeShell}
    '';

    propagatedBuildInputs = with pypkgs; [ xlib ];

    dontBuild = true;

    installPhase = ''
      install -Dm555 -t $out/bin scripts/${pname}
    '';

    meta.mainProgram = pname;
  };

in
stdenv.mkDerivation rec {
  pname = "keyd";
  inherit version src;

  postPatch = ''
    substituteInPlace Makefile \
      --replace PREFIX=/usr PREFIX= \
      --replace CONFIG_DIR=/etc/keyd CONFIG_DIR=${placeholder "out"}/etc \
      --replace SOCKET_PATH=/var/run/keyd/keyd.socket SOCKET_PATH=${placeholder "out"}/run/keyd/keyd.socket

    mkdir -p $out/lib/systemd

    substituteInPlace keyd.service \
      --replace /usr/bin $out/bin
  '';

  buildInputs = [ systemd ];

  enableParallelBuilding = true;

  makeFlags = [
    "DESTDIR=${placeholder "out"}"
  ];

  postInstall = ''
    ln -sf ${lib.getExe appMap} $out/bin/${appMap.pname}
    rm -rf $out/etc
  '';

  passthru.tests.keyd = nixosTests.keyd;

  meta = with lib; {
    description = "A key remapping daemon for linux.";
    homepage = "https://github.com/rvaiya/keyd";
    changelog = "https://github.com/rvaiya/keyd/blob/v${version}/docs/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with maintainers; [ peterhoeg ];
    platforms = platforms.linux;

  };
}
