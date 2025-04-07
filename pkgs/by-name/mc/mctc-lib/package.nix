{
  stdenv,
  lib,
  fetchFromGitHub,
  gfortran,
  meson,
  ninja,
  pkg-config,
  python3,
  json-fortran,
}:

stdenv.mkDerivation rec {
  pname = "mctc-lib";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "grimme-lab";
    repo = "mctc-lib";
    tag = "v${version}";
    hash = "sha256-zR4J9gOKwUIfDZsHMdX/t+mKdTpHKYTZQBYxQMWC8Vk=";
  };

  nativeBuildInputs = [
    gfortran
    meson
    ninja
    pkg-config
    python3
  ];

  buildInputs = [ json-fortran ];

  outputs = [
    "out"
    "dev"
  ];

  doCheck = true;

  postPatch = ''
    patchShebangs --build config/install-mod.py
  '';

  meta = with lib; {
    description = "Modular computation tool chain library";
    mainProgram = "mctc-convert";
    homepage = "https://github.com/grimme-lab/mctc-lib";
    license = licenses.asl20;
    platforms = platforms.linux;
    maintainers = [ maintainers.sheepforce ];
  };
}
