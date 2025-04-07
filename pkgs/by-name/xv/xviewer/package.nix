{
  stdenv,
  lib,
  fetchFromGitHub,
  docbook_xsl,
  exempi,
  gdk-pixbuf,
  glib,
  gobject-introspection,
  gtk3,
  gtk-doc,
  itstool,
  lcms2,
  libexif,
  libjpeg,
  libpeas,
  librsvg,
  libxml2,
  meson,
  ninja,
  pkg-config,
  python3,
  wrapGAppsHook3,
  cinnamon-desktop,
  yelp-tools,
  xapp,
}:

stdenv.mkDerivation rec {
  pname = "xviewer";
  version = "3.4.8";

  src = fetchFromGitHub {
    owner = "linuxmint";
    repo = pname;
    tag = version;
    hash = "sha256-Wn1a/tGNIJNGbgDKoMMMo/oCXrqCXDM1nTUgCZt0O/U=";
  };

  nativeBuildInputs = [
    docbook_xsl
    gobject-introspection
    gtk-doc
    itstool
    meson
    ninja
    pkg-config
    python3
    wrapGAppsHook3
    yelp-tools
  ];

  buildInputs = [
    cinnamon-desktop
    exempi
    gdk-pixbuf
    glib
    gtk3
    lcms2
    libexif
    libjpeg
    libpeas
    librsvg
    libxml2
    xapp
  ];

  meta = with lib; {
    description = "Generic image viewer from Linux Mint";
    mainProgram = "xviewer";
    homepage = "https://github.com/linuxmint/xviewer";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
    maintainers = with maintainers; [ tu-maurice ] ++ teams.cinnamon.members;
  };
}
