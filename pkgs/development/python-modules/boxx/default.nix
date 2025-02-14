{
  lib,
  stdenv,
  buildPythonPackage,
  fetchPypi,
  python,
  xvfb-run,
  matplotlib,
  scikit-image,
  numpy,
  pandas,
  imageio,
  snakeviz,
  pyopengl,
  seaborn,
  torch,
  pythonOlder,
  torchvision,
}:

buildPythonPackage rec {
  pname = "boxx";
  version = "0.10.14";
  format = "setuptools";

  disabled = pythonOlder "3.7";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-unGnmPksEuqFXHTWJkj9Gv2G/qPDgT6AZXYiG2gtkEA=";
  };

  propagatedBuildInputs = [
    matplotlib
    scikit-image
    numpy
    pandas
    imageio
    snakeviz
    pyopengl
    seaborn
  ];

  nativeCheckInputs = [
    xvfb-run
    torch
    torchvision
  ];

  pythonImportsCheck = [ "boxx" ];

  doCheck = stdenv.hostPlatform.isLinux;

  checkPhase = ''
    xvfb-run ${python.interpreter} -m unittest
  '';

  meta = with lib; {
    description = "Tool-box for efficient build and debug for Scientific Computing and Computer Vision";
    homepage = "https://github.com/DIYer22/boxx";
    license = licenses.mit;
    maintainers = with maintainers; [ lucasew ];
  };
}
