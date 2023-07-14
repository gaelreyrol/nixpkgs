{ lib
, fetchzip
, androidenv
}:

androidenv.buildApp {
  name = "x-element-android";
  release = false;

  platformVersions = [ "33" ];

  src = fetchzip {
    url = "https://github.com/vector-im/element-x-android/archive/3414351bfd143c174732da539e25350030249b67.zip";
    hash = "sha256-zmGmwimIUSoMsnjABZMq5C+Emh9yZbAgZZR8OeUnw18=";
  };

  includeNDK = false;

  meta = with lib; {
    description = "Android Matrix messenger application using the Matrix Rust Sdk and Jetpack Compose";
    homepage = "https://github.com/vector-im/element-x-android";
    license = licenses.asl20;
    platforms = platforms.unix;
    maintainers = with maintainers; [ gaelreyrol ];
  };
}
