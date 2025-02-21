{
  lib,
  stdenv,
  fetchurl,
  extra-cmake-modules,
  kdoctools,
  wrapGAppsHook3,
  karchive,
  kconfig,
  kcrash,
  kguiaddons,
  kinit,
  kparts,
  kwindowsystem,
}:

stdenv.mkDerivation rec {
  pname = "krusader";
  version = "2.8.1";

  src = fetchurl {
    url = "mirror://kde/stable/${pname}/${version}/${pname}-${version}.tar.xz";
    hash = "sha256-N78gRRnQqxukCWSvAnQbwijxHpfyjExRjKBdNY3xgoM=";
  };

  patches = [
    # Fix compilation error due to forceful header include
    ./compat-fix.patch
  ];

  nativeBuildInputs = [
    extra-cmake-modules
    kdoctools
    wrapGAppsHook3
  ];

  propagatedBuildInputs = [
    karchive
    kconfig
    kcrash
    kguiaddons
    kinit
    kparts
    kwindowsystem
  ];

  meta = {
    homepage = "http://www.krusader.org";
    description = "Norton/Total Commander clone for KDE";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ sander ];
    mainProgram = "krusader";
  };
}
