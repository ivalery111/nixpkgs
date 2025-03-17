{
  lib,
  arrow,
  buildPythonPackage,
  fetchFromGitHub,
  pint,
  pydantic,
  pythonOlder,
  pytz,
  requests,
  responses,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "stravalib";
  version = "2.3";
  pyproject = true;

  disabled = pythonOlder "3.10";

  src = fetchFromGitHub {
    owner = "stravalib";
    repo = "stravalib";
    tag = "v${version}";
    hash = "sha256-kqR/fujspOyQ6QbWjP2n3NoLVkzzVxAMqntdhY84sl4=";
  };

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    arrow
    pint
    pydantic
    pytz
    requests
    responses
  ];

  # Tests require network access, testing strava API
  doCheck = false;

  pythonImportsCheck = [ "stravalib" ];

  meta = {
    description = "Python library for interacting with Strava v3 REST API";
    homepage = "https://github.com/stravalib/stravalib";
    changelog = "https://github.com/stravalib/stravalib/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ sikmir ];
  };
}
