{ lib
, stdenv
, fetchFromGitHub
, wasm-pack
, nodePackages
, gzip
, buildNpmPackage
, symlinkJoin
, rustPlatform
, strace
}:
let
  pname = "pagefind";
  version = "0.12.0";
  src = fetchFromGitHub {
    owner = "CloudCannon";
    repo = "pagefind";
    rev = "v${version}";
    hash = "sha256-J1HN5vB5qo8PkzmN0YdUkOMaj7dx8QNLJU0KcmKOigo=";
  };
  webBuild = buildNpmPackage {
    inherit version;
    pname = "${pname}-web";

    src = "${src}/pagefind_web";

    npmDepsHash = lib.fakeHash;

    postPatch = ''
      substituteInPlace build.js --replace "pkg/pagefind_web.js" "vendor/"
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp vendor/* $out

      runHook postInstall
    '';
  };
  uiBuild = folder: hash: buildNpmPackage {
    inherit version;
    pname = "${pname}-ui-${toString folder}";

    src = "${src}/pagefind_ui/${toString folder}";

    npmDepsHash = hash;

    postPatch = ''
      # esbuild tries to create build files in ../../pagefind.
      substituteInPlace build.js --replace "../../pagefind/vendor/" "./vendor/"
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp vendor/* $out

      runHook postInstall
    '';
  };
  uiBuilds = symlinkJoin {
    name = "${pname}-ui-builds";
    paths = lib.mapAttrsToList uiBuild {
      default = "sha256-vLhxfalyv9PfrSlqn6hl6so7P7NVdPz8zXeF89MebLU=";
      modular = "sha256-Zut/PqA/shF0SQz7rPSftKfCEWagG80lnrIFaYREKh4=";
    };
  };
in rustPlatform.buildRustPackage rec {
  inherit pname version src;

  configurePhase = ''
    runHook preConfigure

    mkdir -p pagefind/vendor/wasm
    cp ${uiBuilds}/* pagefind/vendor/
    ls pagefind/vendor/

    runHook postConfigure
  '';

  buildInputs = [ strace wasm-pack nodePackages.nodejs gzip uiBuilds ];

  buildPhase = ''
    runHook preBuild

    set -x

    cd pagefind_web

    ${wasm-pack}/bin/wasm-pack build --release -t no-modules

    ${nodePackages.nodejs}/bin/node build.js

    mv pkg/pagefind_web.js ../../pagefind/vendor/pagefind_web.${version}.js
    printf 'pagefind_dcd' > ../../pagefind/vendor/pagefind_web.${version}.js
    cat pkg/pagefind_web_bg.wasm >> ../../pagefind/vendor/pagefind_web_bg.unknown.${version}.wasm
    gzip --best ../../pagefind/vendor/pagefind_web_bg.unknown.${version}.wasm

    grep -e pagefind_stem/ Cargo.toml | while read line ; do
      ${wasm-pack}/bin/wasm-pack build --release -t no-modules --features ${line:0:2}
      printf 'pagefind_dcd' > ../../pagefind/vendor/pagefind_web_bg.${line:0:2}.${version}.wasm
      cat pkg/pagefind_web_bg.wasm >> ../../pagefind/vendor/pagefind_web_bg.${line:0:2}.${version}.wasm
      gzip --best ../../pagefind/vendor/pagefind_web_bg.${line:0:2}.${version}.wasm
    done

    ls -lh ../../pagefind/vendor/wasm

    runHook cargoBuildHook
    runHook postBuild
  '';

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  meta = with lib; {
    description = "Static low-bandwidth search at scale";
    homepage = "https://github.com/CloudCannon/pagefind";
    changelog = "https://github.com/CloudCannon/pagefind/blob/${src.rev}/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with maintainers; [ gaelreyrol ];
    mainProgram = "pagefind";
  };
}
