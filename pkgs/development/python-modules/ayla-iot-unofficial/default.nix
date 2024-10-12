{
  aiohttp,
  buildPythonPackage,
  fetchFromGitHub,
  lib,
  pytest-asyncio,
  pytestCheckHook,
  requests,
  setuptools,
  ujson,
}:

buildPythonPackage rec {
  pname = "ayla-iot-unofficial";
  version = "1.4.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "rewardone";
    repo = "ayla-iot-unofficial";
    rev = "refs/tags/v${version}";
    hash = "sha256-E0vDaKZxrOwzRsqVYw+RVgFYgRB+klW1yb07KA+9zWc=";
  };

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    requests
    ujson
  ];

  pythonImportsCheck = [ "ayla_iot_unofficial" ];

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  pytestFlagsArray = [ "tests/ayla_iot_unofficial.py" ];

  # tests interact with the actual API
  doCheck = false;

  meta = {
    changelog = "https://github.com/rewardone/ayla-iot-unofficial/releases/tag/v${version}";
    description = "Unofficial python library for interacting with the Ayla IoT API";
    homepage = "https://github.com/rewardone/ayla-iot-unofficial";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
