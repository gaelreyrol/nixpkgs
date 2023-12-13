{ buildPecl
, lib
, fetchFromGitHub
, mpdecimal
}:

let
  version = "1.4.0";
in buildPecl {
  inherit version;
  pname = "decimal";

  src = fetchFromGitHub {
    owner = "php-decimal";
    repo = "ext-decimal";
    rev = "v${version}";
    hash = "sha256-1xP6DqRWK5fFaPNwXXzTjZVkFzxmG9Uzy8qxrYjYvbA=";
  };

  configureFlags = [
    "--with-libmpdec-path=${mpdecimal}"
  ];

  doCheck = true;

  meta = {
    changelog = "https://github.com/php-decimal/ext-decimal/releases/tag/${version}";
    description = "Correctly-rounded, arbitrary precision decimal floating-point arithmetic in PHP 7";
    homepage = "https://github.com/php-decimal/ext-decimal";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ gaelreyrol ];
  };
}
