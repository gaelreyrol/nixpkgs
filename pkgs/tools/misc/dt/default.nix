{ lib
, stdenv
, fetchFromGitHub
, pkg-config
, zig
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dt";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "booniepepper";
    repo = "dt";
    rev = "v${finalAttrs.version}";
    hash = "sha256-5YEHPS+dzgtmPnvfNIjxx7/85/WQrXrRZRQM92OUVPs=";
  };

  nativeBuildInputs = [
    pkg-config
    zig
  ];

  dontConfigure = true;

  flags = [ "-Drelease-safe" "-Dcpu=baseline"];

  preBuild = ''
    export HOME=$TMPDIR
  '';

  buildPhase = ''
    runHook preBuild;

    zig build ${builtins.concatStringsSep " " finalAttrs.flags} --prefix $out

    runHook postBuild;
  '';


  meta = with lib; {
    description = "duct tape for your unix pipes";
    homepage = "https://github.com/booniepepper/dt";
    changelog = "https://github.com/booniepepper/dt/releases/tag/v${finalAttrs.version}";
    license = licenses.bsd3;
    platforms = platforms.unix;
    maintainers = with maintainers; [ gaelreyrol ];
  };
})
