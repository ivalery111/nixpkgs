{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  bash,
  docbook_xml_dtd_42,
  docbook-xsl-nons,
  glib,
  gobject-introspection,
  gtk3,
  intltool,
  libnotify,
  libxml2,
  libxslt,
  networkmanagerapplet,
  pkg-config,
  python3,
  wrapGAppsNoGuiHook,
  withGui ? false,
}:

let
  pythonPath = python3.withPackages (
    ps:
    with ps;
    [
      dbus-python
      nftables
      pygobject3
    ]
    ++ lib.optionals withGui [
      pyqt5
      pyqt5-sip
    ]
  );
in
stdenv.mkDerivation rec {
  pname = "firewalld";
  version = "2.3.0";

  src = fetchFromGitHub {
    owner = "firewalld";
    repo = "firewalld";
    rev = "v${version}";
    sha256 = "sha256-ubE1zMIOcdg2+mgXsk6brCZxS1XkvJYwVY3E+UXIIiU=";
  };

  patches = [
    ./respect-xml-catalog-files-var.patch
  ];

  postPatch =
    ''
      substituteInPlace src/firewall/config/__init__.py.in \
        --replace "/usr/share" "$out/share"

      for file in config/firewall-{applet,config}.desktop.in; do
        substituteInPlace $file \
          --replace "/usr/bin/" "$out/bin/"
      done
    ''
    + lib.optionalString withGui ''
      substituteInPlace src/firewall-applet.in \
        --replace "/usr/bin/nm-connection-editor" "${networkmanagerapplet}/bin/nm-connection-editor"
    '';

  nativeBuildInputs =
    [
      autoconf
      automake
      docbook_xml_dtd_42
      docbook-xsl-nons
      glib
      intltool
      libxml2
      libxslt
      pkg-config
      python3
      python3.pkgs.wrapPython
    ]
    ++ lib.optionals withGui [
      gobject-introspection
      wrapGAppsNoGuiHook
    ];

  buildInputs =
    [
      bash
      glib
    ]
    ++ lib.optionals withGui [
      gtk3
      libnotify
      pythonPath
    ];

  preConfigure = ''
    ./autogen.sh
  '';

  dontWrapGApps = true;

  preFixup = lib.optionalString withGui ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  postFixup = ''
    chmod +x $out/share/firewalld/*.py $out/share/firewalld/testsuite/python/*.py $out/share/firewalld/testsuite/{,integration/}testsuite
    patchShebangs --host $out/share/firewalld/testsuite/{,integration/}testsuite $out/share/firewalld/*.py
    wrapPythonProgramsIn "$out/bin" "$out ${pythonPath}"
    wrapPythonProgramsIn "$out/share/firewalld/testsuite/python" "$out ${pythonPath}"
  '';

  meta = {
    description = "Firewall daemon with D-Bus interface";
    homepage = "https://firewalld.org";
    downloadPage = "https://github.com/firewalld/firewalld/releases";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ prince213 ];
    platforms = lib.platforms.linux;
  };
}
