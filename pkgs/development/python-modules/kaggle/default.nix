{
  bleach,
  buildPythonPackage,
  certifi,
  charset-normalizer,
  fetchPypi,
  hatchling,
  idna,
  lib,
  python-dateutil,
  python-slugify,
  requests,
  setuptools,
  six,
  text-unidecode,
  tqdm,
  urllib3,
  webencodings,
}:

buildPythonPackage rec {
  pname = "kaggle";
  version = "1.7.4.2";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-CxRDWPQYe96D6KAzVUm/c2+0ZmlycqE1qYXrbSxvnLY=";
  };

  build-system = [ hatchling ];

  dependencies = [
    bleach
    certifi
    charset-normalizer
    idna
    python-dateutil
    python-slugify
    requests
    setuptools
    six
    text-unidecode
    tqdm
    urllib3
    webencodings
  ];

  # Tests try to access the network.
  checkPhase = ''
    export HOME="$TMP"
    mkdir -p "$HOME/.kaggle/"
    echo '{"username":"foobar","key":"00000000000000000000000000000000"}' > "$HOME/.kaggle/kaggle.json"
    $out/bin/kaggle --help > /dev/null
  '';
  pythonImportsCheck = [ "kaggle" ];

  meta = with lib; {
    description = "Official API for https://www.kaggle.com, accessible using a command line tool implemented in Python 3";
    mainProgram = "kaggle";
    homepage = "https://github.com/Kaggle/kaggle-api";
    license = licenses.asl20;
    maintainers = with maintainers; [ mbalatsko ];
  };
}
