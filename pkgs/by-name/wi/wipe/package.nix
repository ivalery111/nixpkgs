{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
}:

stdenv.mkDerivation rec {
  pname = "wipe";
  version = "2.3.1";

  src = fetchurl {
    url = "mirror://sourceforge/wipe/${version}/${pname}-${version}.tar.bz2";
    sha256 = "180snqvh6k6il6prb19fncflf2jcvkihlb4w84sbndcv1wvicfa6";
  };

  postPatch = ''
    # Do not strip binary during install
    substituteInPlace Makefile.in \
      --replace-fail '$(INSTALL_BIN) -s' '$(INSTALL_BIN)'
  '';

  nativeBuildInputs = [ autoreconfHook ];

  # fdatasync is undocumented on darwin with no header file which breaks the build.
  # use fsync instead.
  configureFlags = lib.optional stdenv.hostPlatform.isDarwin "ac_cv_func_fdatasync=no";

  patches = [ ./fix-install.patch ];

  meta = {
    description = "Secure file wiping utility";
    homepage = "https://wipe.sourceforge.net/";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.all;
    maintainers = [ lib.maintainers.abbradar ];
    mainProgram = "wipe";
  };
}
