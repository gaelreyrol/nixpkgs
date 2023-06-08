{ lib, stdenv, fetchzip, fetchFromGitHub, callPackage }:

let
  resources = callPackage ./resources.nix { };
  sqlite3 = fetchzip {
    url = "https://www.sqlite.org/2022/sqlite-amalgamation-3400000.zip";
    sha256 = "sha256-qo9Afan8WUIEdBLfRuyy2QarQfKAQOyXqX1+JBhtwjA=";
  };
in
stdenv.mkDerivation {
  pname = "barracuda";
  version = "2023-06-02";

  src = fetchFromGitHub {
    owner = "RealTimeLogic";
    repo = "BAS";
    rev = "d7075920019acff07728cef8bdcf36ec10d280d0";
    hash = "sha256-0qQJc5+wU9RBeMaUJ05o8gPiF62nJN3ooEL1IG+5CZo=";
  };

  configurePhase = ''
    runHook preConfigure

    cp ${sqlite3}/* ./src

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    gcc \
      -o examples/MakoServer/mako \
      -fmerge-all-constants \
      -lpthread -lm -ldl \
      -O3 -Os -w \
      -DLUA_USE_LINUX \
      -DUSE_EMBEDDED_ZIP=0 \
      -DBA_FILESIZE64 \
      -DMAKO \
      -DUSE_LUAINTF \
      -Iinc \
      -Iinc/arch/Posix \
      -Iinc/arch/NET/Posix \
      src/BAS.c \
      src/arch/Posix/ThreadLib.c \
      src/arch/NET/generic/SoDisp.c \
      src/DiskIo/posix/BaFile.c \
      examples/MakoServer/src/MakoMain.c \
      src/ls_sqlite3.c \
      src/luasql.c \
      src/sqlite3.c

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp ${resources} $out/bin/mako.zip
    cp examples/MakoServer/mako* $out/bin/

    runHook postInstall
  '';

  meta = with lib; {
    description = "Embedded Web Server Library with Integrated Scripting Engine";
    homepage = "https://github.com/RealTimeLogic/BAS";
    license = licenses.gpl2;
    maintainers = with maintainers; [ gaelreyrol ];
    platforms = platforms.all;
  };
}
