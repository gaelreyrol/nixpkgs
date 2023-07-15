{ lib
, rustPlatform
, fetchFromGitHub
, makeDesktopItem
, copyDesktopItems
, makeWrapper
, writeText
, cmake
, yasm
, nasm
, pkg-config
, clang
, gtk3
, xdotool
, alsa-lib
, wrapGAppsHook
, libXfixes
, libXtst
, libvpx
, libyuv
, libopus
, libsciter
, libaom
, atk
, bzip2
, cairo
, dbus
, gdk-pixbuf
, glib
, gst_all_1
, libgit2
, libpulseaudio
, libsodium
, pam
, pango
, zlib
, zstd
, stdenv
, darwin
}:

rustPlatform.buildRustPackage rec {
  pname = "rustdesk";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "rustdesk";
    repo = "rustdesk";
    rev = version;
    hash = "sha256-83YbhH21gpKWnUdCSOKiAf/pI2fJt3tT/U8xxZdIqjo=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "confy-0.4.0-2" = "sha256-r5VeggXrIq5Cwxc2WSrxQDI5Gvbw979qIUQfMKHgBUI=";
      "evdev-0.11.5" = "sha256-aoPmjGi/PftnH6ClEWXHvIj0X3oh15ZC1q7wPC1XPr0=";
      "hwcodec-0.1.0" = "sha256-Ld79cSR9JnU9mjgjEYKMdvCXZcE5LyRrNn7028v+J1I=";
      "impersonate_system-0.1.0" = "sha256-qbaTw9gxMKDjX5pKdUrKlmIxCxWwb99YuWPDvD2A3kY=";
      "keepawake-0.4.3" = "sha256-sLQf9q88dB2bkTN01UlxRWSpoF1kFsqqpYC4Sw6cbEY=";
      "machine-uid-0.3.0" = "sha256-rEOyNThg6p5oqE9URnxSkPtzyW8D4zKzLi9pAnzTElE=";
      "magnum-opus-0.4.0" = "sha256-U5uuN4YolOYDnFNbtPpwYefcBDTUUyioui0UCcW8dyo=";
      "mouce-0.2.1" = "sha256-3PtNEmVMXgqKV4r3KiKTkk4oyCt4BKynniJREE+RyFk=";
      "pam-0.7.0" = "sha256-qe2GH6sfGEUnqLiQucYLB5rD/GyAaVtm9pAxWRb1H3Q=";
      "parity-tokio-ipc-0.7.3-2" = "sha256-WXDKcDBaJuq4K9gjzOKMozePOFiVX0EqYAFamAz/Yvw=";
      "rdev-0.5.0-2" = "sha256-/1mk2TkyhcU6MYZwpcF2HIlKX6BqQhEsEkIC4AVOgQM=";
      "reqwest-0.11.18" = "sha256-3k2wcVD+DzJEdP/+8BqP9qz3tgEWcbWZj5/CjrZz5LY=";
      "rust-pulsectl-0.2.12" = "sha256-8jXTspWvjONFcvw9/Z8C43g4BuGZ3rsG32tvLMQbtbM=";
      "sciter-rs-0.5.57" = "sha256-NQPDlMQ0sGY8c9lBMlplT82sNjbgJy2m/+REnF3fz8M=";
      "tao-0.19.1" = "sha256-Rnj4JC3u7avB9mvpRZMO9iq7Icb2HsGdQg3ZRYhsC08=";
      "tfc-0.6.1" = "sha256-ukxJl7Z+pUXCjvTsG5Q0RiXocPERWGsnAyh3SIWm0HU=";
      "tokio-socks-0.5.1-2" = "sha256-x3aFJKo0XLaCGkZLtG9GYA+A/cGGedVZ8gOztWiYVUY=";
      "tray-icon-0.5.1" = "sha256-1VyUg8V4omgdRIYyXhfn8kUvhV5ef6D2cr2Djz2uQyc=";
      "x11-2.19.0" = "sha256-GDCeKzUtvaLeBDmPQdyr499EjEfT6y4diBMzZVEptzc=";
    };
  };

  # Change magnus-opus version to upstream so that it does not use
  # vcpkg for libopus since it does not work.
  # cargoPatches = [
  #   ./cargo.patch
  # ];

  nativeBuildInputs = [
    pkg-config
    cmake
    makeWrapper
    copyDesktopItems
    yasm
    nasm
    clang
    wrapGAppsHook
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    alsa-lib
    atk
    bzip2
    cairo
    dbus
    gdk-pixbuf
    glib
    gst_all_1.gst-plugins-base
    gst_all_1.gstreamer
    gtk3
    libgit2
    libpulseaudio
    libsodium
    pam
    pango
    zlib
    zstd
    libaom
    libopus
    libXtst
    libXfixes
    libyuv
    libvpx
    xdotool
  ] ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.AppKit
    darwin.apple_sdk.frameworks.CoreAudio
    darwin.apple_sdk.frameworks.CoreFoundation
    darwin.apple_sdk.frameworks.CoreGraphics
    darwin.apple_sdk.frameworks.Foundation
    darwin.apple_sdk.frameworks.IOKit
    darwin.apple_sdk.frameworks.Security
    darwin.apple_sdk.frameworks.SystemConfiguration
  ];

  env = {
    SODIUM_USE_PKG_CONFIG = true;
    ZSTD_SYS_USE_PKG_CONFIG = true;
  };

  # Change magnus-opus version to upstream so that it does not use
  # vcpkg for libopus since it does not work.
  cargoPatches = [
    ./cargo.patch
  ];

  # Manually simulate a vcpkg installation so that it can link the libraries
  # properly.
  postUnpack =
    let
      vcpkg_target = "x64-linux";

      updates_vcpkg_file = writeText "update_vcpkg_rustdesk"
        ''
          Package : libyuv
          Architecture : ${vcpkg_target}
          Version : 1.0
          Status : is installed

          Package : libvpx
          Architecture : ${vcpkg_target}
          Version : 1.0
          Status : is installed
        '';
    in
    ''
      export VCPKG_ROOT="$TMP/vcpkg";

      mkdir -p $VCPKG_ROOT/.vcpkg-root
      mkdir -p $VCPKG_ROOT/installed/${vcpkg_target}/lib
      mkdir -p $VCPKG_ROOT/installed/vcpkg/updates
      ln -s ${updates_vcpkg_file} $VCPKG_ROOT/installed/vcpkg/status
      mkdir -p $VCPKG_ROOT/installed/vcpkg/info
      touch $VCPKG_ROOT/installed/vcpkg/info/libyuv_1.0_${vcpkg_target}.list
      touch $VCPKG_ROOT/installed/vcpkg/info/libvpx_1.0_${vcpkg_target}.list

      ln -s ${libvpx.out}/lib/* $VCPKG_ROOT/installed/${vcpkg_target}/lib/
      ln -s ${libyuv.out}/lib/* $VCPKG_ROOT/installed/${vcpkg_target}/lib/
    '';

  # Checks require an active X display.
  doCheck = false;

  desktopItems = [
    (makeDesktopItem {
      name = "rustdesk";
      exec = meta.mainProgram;
      icon = "rustdesk";
      desktopName = "RustDesk";
      comment = meta.description;
      genericName = "Remote Desktop";
      categories = [ "Network" ];
    })
  ];

  postPatch = ''
    rm Cargo.lock
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  # Add static ui resources and libsciter to same folder as binary so that it
  # can find them.
  postInstall = ''
    mkdir -p $out/{share/src,lib/rustdesk}

    # so needs to be next to the executable
    mv $out/bin/rustdesk $out/lib/rustdesk
    ln -s ${libsciter}/lib/libsciter-gtk.so $out/lib/rustdesk

    makeWrapper $out/lib/rustdesk/rustdesk $out/bin/rustdesk \
      --chdir "$out/share"

    cp -a $src/src/ui $out/share/src

    install -Dm0644 $src/logo.svg $out/share/icons/hicolor/scalable/apps/rustdesk.svg
  '';

  meta = with lib; {
    description = "Yet another remote desktop software";
    homepage = "https://rustdesk.com";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ocfox leixb ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "rustdesk";
  };
}
