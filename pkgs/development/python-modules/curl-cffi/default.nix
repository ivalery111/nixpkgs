{
  stdenv,
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  curl-impersonate-chrome,
  cffi,
  certifi,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "curl-cffi";
  version = "0.7.4";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "lexiforest";
    repo = "curl_cffi";
    rev = "refs/tags/v${version}";
    hash = "sha256-Q1VppzQ1Go+ia1D1BemTf40o9wV0miWyoGy/tY+95qE==";
  };

  patches = [ ./use-system-libs.patch ];
  buildInputs = [ curl-impersonate-chrome ];

  build-system = [
    cffi
    setuptools
  ];

  dependencies = [
    cffi
    certifi
    typing-extensions
  ];

  env = lib.optionalAttrs stdenv.cc.isGNU {
    NIX_CFLAGS_COMPILE = "-Wno-error=incompatible-pointer-types";
  };

  pythonImportsCheck = [ "curl_cffi" ];

  meta = with lib; {
    description = "Python binding for curl-impersonate via cffi";
    homepage = "https://curl-cffi.readthedocs.io";
    license = licenses.mit;
    maintainers = with maintainers; [ chuangzhu ];
  };
}
