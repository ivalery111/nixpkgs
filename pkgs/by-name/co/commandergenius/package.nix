{
  lib,
  stdenv,
  fetchFromGitLab,
  SDL2,
  SDL2_image,
  pkg-config,
  libvorbis,
  libGL,
  boost,
  cmake,
  zlib,
  curl,
  SDL2_mixer,
  SDL2_ttf,
  python3,
}:

stdenv.mkDerivation rec {
  pname = "commandergenius";
  version = "3.5.2";

  src = fetchFromGitLab {
    owner = "Dringgstein";
    repo = "Commander-Genius";
    tag = "v${version}";
    hash = "sha256-4WfHdgn8frcDVa3Va6vo/jZihf09vIs+bNdAxScgovE=";
  };

  buildInputs = [
    SDL2
    SDL2_image
    SDL2_mixer
    SDL2_ttf
    libGL
    boost
    libvorbis
    zlib
    curl
    python3
  ];

  cmakeFlags = [
    "-DCMAKE_INSTALL_PREFIX=${placeholder "out"}"
    "-DSHAREDIR=${placeholder "out"}/share"
  ];

  makeFlags = [
    "DESTDIR=${placeholder "out"}"
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  postPatch = ''
    NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE $(sdl2-config --cflags)"
    sed -i 's,APPDIR games,APPDIR bin,' src/install.cmake
  '';

  meta = with lib; {
    description = "Modern Interpreter for the Commander Keen Games";
    longDescription = ''
      Commander Genius is an open-source clone of
      Commander Keen which allows you to play
      the games, and some of the mods
      made for it. All of the original data files
      are required to do so
    '';
    homepage = "https://github.com/gerstrong/Commander-Genius";
    maintainers = with maintainers; [ hce ];
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
  };
}
