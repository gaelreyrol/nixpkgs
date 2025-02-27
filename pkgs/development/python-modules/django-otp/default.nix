{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  hatchling,
  django,
  freezegun,
  qrcode,
  pytest,
  python,
}:

buildPythonPackage rec {
  pname = "django-otp";
  version = "1.5.4";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "django-otp";
    repo = "django-otp";
    tag = "v${version}";
    hash = "sha256-Hwi0Z5/e91peGbp+GvL/gCtUI4hcJ4kevJMWe9sFvYk=";
  };

  build-system = [ hatchling ];

  dependencies = [
    django
    qrcode
  ];

  env.DJANGO_SETTINGS_MODUOLE = "test.test_project.settings";

  nativeCheckInputs = [
    freezegun
    pytest
  ];

  checkPhase = ''
    runHook preCheck

    export PYTHONPATH=$PYTHONPATH:test
    export DJANGO_SETTINGS_MODULE=test_project.settings
    ${python.interpreter} -m django test django_otp

    runHook postCheck
  '';

  pytestFlagsArray = [ "src/django_otp/test.py" ];

  pythonImportsCheck = [ "django_otp" ];

  meta = with lib; {
    homepage = "https://github.com/django-otp/django-otp";
    changelog = "https://github.com/django-otp/django-otp/blob/${src.tag}/CHANGES.rst";
    description = "Pluggable framework for adding two-factor authentication to Django using one-time passwords";
    license = licenses.bsd2;
    maintainers = [ ];
  };
}
