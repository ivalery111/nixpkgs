{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  qtbase,
  qtsvg,
  lxqt-build-tools,
  wrapQtAppsHook,
  gitUpdater,
  version ? "4.1.0",
}:

stdenv.mkDerivation rec {
  pname = "libqtxdg";
  inherit version;

  src = fetchFromGitHub {
    owner = "lxqt";
    repo = pname;
    tag = version;
    hash =
      {
        "3.12.0" = "sha256-y+3noaHubZnwUUs8vbMVvZPk+6Fhv37QXUb//reedCU=";
        "4.1.0" = "sha256-Efn08a8MkR459Ww0WiEb5GXKgQzJwKupIdL2TySpivE=";
      }
      ."${version}";
  };

  nativeBuildInputs = [
    cmake
    lxqt-build-tools
    wrapQtAppsHook
  ];

  buildInputs = [
    qtbase
    qtsvg
  ];

  preConfigure = ''
    cmakeFlagsArray+=(
      "-DQTXDGX_ICONENGINEPLUGIN_INSTALL_PATH=$out/$qtPluginPrefix/iconengines"
      "-DCMAKE_INSTALL_INCLUDEDIR=include"
      "-DCMAKE_INSTALL_LIBDIR=lib"
    )
  '';

  passthru.updateScript = gitUpdater { };

  meta = with lib; {
    homepage = "https://github.com/lxqt/libqtxdg";
    description = "Qt implementation of freedesktop.org xdg specs";
    license = licenses.lgpl21Plus;
    platforms = platforms.linux;
    maintainers = teams.lxqt.members;
  };
}
