{ lib
, stdenv
, fetchzip
, cmake
, coreutils
, llvmPackages
, libxml2
, zlib
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "zig";
  version = "0.11.0";

  src = fetchzip {
    url = "https://ziglang.org/builds/zig-0.11.0-dev.3986+e05c242cd.tar.xz";
    hash = "sha256-4H6VYTTdELsuUZyQIsSiI2ni49zOMLQIs11R24vJC+U=";
  };

  outputs = [ "out" "doc" ];

  nativeBuildInputs = [
    cmake
    llvmPackages.llvm.dev
  ];

  buildInputs = [
    coreutils
    libxml2
    zlib
  ] ++ (with llvmPackages; [
    libclang
    lld
    llvm
  ]);

  # Zig's build looks at /usr/bin/env to find dynamic linking info. This doesn't
  # work in Nix's sandbox. Use env from our coreutils instead.
  postPatch = ''
    substituteInPlace lib/std/zig/system/NativeTargetInfo.zig \
      --replace "/usr/bin/env" "${coreutils}/bin/env"
  '';

  cmakeFlags = [
    # file RPATH_CHANGE could not write new RPATH
    "-DCMAKE_SKIP_BUILD_RPATH=ON"

    # always link against static build of LLVM
    "-DZIG_STATIC_LLVM=ON"

    # ensure determinism in the compiler build
    "-DZIG_TARGET_MCPU=baseline"
  ];

  env.ZIG_GLOBAL_CACHE_DIR = "$TMPDIR/zig-cache";

  postBuild = ''
    ./zig2 build-exe ../doc/docgen.zig
    ./docgen ./zig2 ../doc/langref.html.in ./langref.html
  '';

  postInstall = ''
    install -Dm644 -t $doc/share/doc/zig-${finalAttrs.version}/html ./langref.html
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    runHook preInstallCheck

    $out/bin/zig test --cache-dir "$TMPDIR/cache-dir" -I $src/test $src/test/behavior.zig

    runHook postInstallCheck
  '';

  meta = {
    homepage = "https://ziglang.org/";
    description =
      "General-purpose programming language and toolchain for maintaining robust, optimal, and reusable software";
    changelog = "https://ziglang.org/download/${finalAttrs.version}/release-notes.html";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ aiotter andrewrk AndersonTorres ];
    platforms = lib.platforms.unix;
  };
})
