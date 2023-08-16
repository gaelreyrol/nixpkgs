{ lib
, stdenv
, fetchFromGitHub
, autoreconfHook
, autoconf-archive
, automake
, pkg-config
, openssl
}:

stdenv.mkDerivation rec {
  pname = "ms-tpm-20-ref";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "Microsoft";
    repo = "ms-tpm-20-ref";
    rev = "f74c0d9686625c02b0fdd5b2bbe792a22aa96cb6";
    hash = "sha256-ulJ1d0Te/AXV1F7U+8RdGwQGxJUxBmGdAGf7ZUDrDUY=";
  };

  sourceRoot = "source/TPMCmd";

  nativeBuildInputs = [ autoreconfHook autoconf-archive pkg-config ];

  buildInputs = [ openssl ];

  postPatch = "sh ./bootstrap";

  # Support OpenSSL up to 3.1.x - https://github.com/microsoft/ms-tpm-20-ref/pull/93
  patches = [ ./openssl-3.1.x.patch ];
  
  postInstall = ''
    mkdir -p $out/{lib,include}

    cp Platform/src/libplatform.a $out/lib
    cp tpm/src/libtpm.a $out/lib

    cp Platform/include/*.h $out/include
    cp Platform/include/prototypes/*.h $out/include

    cp Simulator/include/*.h $out/include
    cp Simulator/include/prototypes/*.h $out/include

    cp tpm/include/*.h $out/include
    mkdir -p $out/include/{Ossl,Ltc}
    cp tpm/include/prototypes/*.h $out/include
    cp tpm/include/Ossl/*.h $out/include/Ossl
    cp tpm/include/Ltc/*.h $out/include/Ltc
  '';

  meta = with lib; {
    description = "Reference implementation of the TCG Trusted Platform Module 2.0 specification";
    homepage = "https://github.com/Microsoft/ms-tpm-20-ref/";
    license = licenses.bsd2;
    maintainers = with maintainers; [ gaelreyrol ];
    mainProgram = "tpm2-simulator";
  };
}
