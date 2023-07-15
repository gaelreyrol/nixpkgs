{ lib
, stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "flipperzero-firmware";
  version = "0.86.2";

  src = fetchFromGitHub {
    owner = "flipperdevices";
    repo = "flipperzero-firmware";
    rev = finalAttrs.version;
    hash = "sha256-uzvtY5ahkWtEyJRrXEp+6T9e5P5HJ6QFKYmNtqo3clw=";
    fetchSubmodules = true;
  };

  meta = with lib; {
    description = "Flipper Zero firmware source code";
    homepage = "https://github.com/flipperdevices/flipperzero-firmware";
    changelog = "https://github.com/flipperdevices/flipperzero-firmware/releases/tag/${finalAttrs.version}";
    license = licenses.gpl3Only;
    platforms = platforms.unix;
    maintainers = with maintainers; [ gaelreyrol ];
  };
})
