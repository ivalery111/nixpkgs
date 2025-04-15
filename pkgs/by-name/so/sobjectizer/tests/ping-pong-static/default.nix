{
  cmake,
  lib,
  stdenv,
  sobjectizer
}:

stdenv.mkDerivation rec {
  name = "ping-pong-static";
  src = ./.;
  nativeBuildInputs = [
    cmake
    sobjectizer
  ];

  doCheck = true;
  checkPhase = ''
    ./${name} -r 1000
  '';
}
