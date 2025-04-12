{
  lib,
  aiohttp,
  aiohttp-sse-client2,
  aioresponses,
  buildPythonPackage,
  fetchFromGitHub,
  mashumaro,
  orjson,
  poetry-core,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  pythonOlder,
  syrupy,
  yarl,
}:

buildPythonPackage rec {
  pname = "pysmartthings";
  version = "3.0.4";
  pyproject = true;

  disabled = pythonOlder "3.12";

  src = fetchFromGitHub {
    owner = "andrewsayre";
    repo = "pysmartthings";
    tag = "v${version}";
    hash = "sha256-FM1c6SRwTUHfbTmk7Z+hsyvpdPp+uyeqnviI6VzPGT4=";
  };

  build-system = [ poetry-core ];

  dependencies = [
    aiohttp
    aiohttp-sse-client2
    mashumaro
    orjson
    yarl
  ];

  nativeCheckInputs = [
    aioresponses
    pytest-asyncio
    pytest-cov-stub
    pytestCheckHook
    syrupy
  ];

  pythonImportsCheck = [ "pysmartthings" ];

  meta = with lib; {
    description = "Python library for interacting with the SmartThings cloud API";
    homepage = "https://github.com/andrewsayre/pysmartthings";
    changelog = "https://github.com/andrewsayre/pysmartthings/releases/tag/${src.tag}";
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ fab ];
  };
}
