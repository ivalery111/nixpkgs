{
  lib,
  buildPythonPackage,
  pythonOlder,
  fetchPypi,
  hatchling,
  pyyaml,
  more-itertools,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "tap.py";
  version = "3.2.1";
  pyproject = true;

  disabled = pythonOlder "3.9";

  src = fetchPypi {
    pname = "tap_py";
    inherit version;
    hash = "sha256-0DyeavClb62ZTxxp8UBB5naBHXPu7vIL9Ad8Q9Yh1gg=";
  };

  build-system = [
    hatchling
  ];

  optional-dependencies = {
    yaml = [
      pyyaml
      more-itertools
    ];
  };

  nativeCheckInputs = [ pytestCheckHook ];

  pythonImportsCheck = [ "tap" ];

  meta = with lib; {
    description = "Set of tools for working with the Test Anything Protocol (TAP) in Python";
    homepage = "https://github.com/python-tap/tappy";
    changelog = "https://tappy.readthedocs.io/en/latest/releases.html";
    mainProgram = "tappy";
    license = licenses.bsd2;
    maintainers = with maintainers; [ sfrijters ];
  };
}
