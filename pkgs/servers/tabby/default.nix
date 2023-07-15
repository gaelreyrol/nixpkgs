{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, cmake
, protobuf
, openssl
, mkl
, oneDNN
, openblas
, cudatoolkit
, cudaPackages
}:

rustPlatform.buildRustPackage {
  pname = "tabby";
  version = "unstable-2023-07-14";

  src = fetchFromGitHub {
    owner = "TabbyML";
    repo = "tabby";
    # No stable release yet
    rev = "3457599db5227d23dd1dcd78cf180bcdf8841739";
    hash = "sha256-Zj+Sd/9VYFmx/c7km4UarWV4aDh2SEi28tvjT6PF6JU=";
    fetchSubmodules = true;
  };

  cargoHash = "sha256-0Lf2hYWX8GWuv7gS56wGCt5pBkRQxsssG1lndIJMgQM=";

  nativeBuildInputs = [ pkg-config cmake protobuf ];

  buildInputs = [
    openssl
    # needed by ctranslate2-bindings crate
    mkl
    oneDNN
    openblas
    cudatoolkit
    cudaPackages.cudnn
  ];

  meta = with lib; {
    description = "Self-hosted AI coding assistant";
    homepage = "https://github.com/TabbyML/tabby";
    license = licenses.asl20;
    platforms = platforms.unix;
    maintainers = with maintainers; [ gaelreyrol ];
    mainProgram = "tabby";
  };
}
