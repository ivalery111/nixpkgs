{
  lib,
  mkDerivation,
  fetchurl,
  libpulseaudio,
  alsa-lib,
  pkg-config,
  qtbase,
}:

mkDerivation rec {
  pname = "unixcw";
  version = "3.5.1";

  src = fetchurl {
    url = "mirror://sourceforge/unixcw/unixcw_${version}.orig.tar.gz";
    hash = "sha256-Xzqs2KJuFubv9DfHrh6bOJlW+xN+6z3iRnDOBd5Hnno=";
  };

  patches = [
    ./remove-use-of-dlopen.patch
  ];

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libpulseaudio
    alsa-lib
    qtbase
  ];

  CFLAGS = "-lasound -lpulse-simple";

  meta = {
    description = "Sound characters as Morse code on the soundcard or console speaker";
    longDescription = ''
      unixcw is a project providing libcw library and a set of programs
      using the library: cw, cwgen, cwcp and xcwcp.
      The programs are intended for people who want to learn receiving
      and sending Morse code.
      unixcw is developed and tested primarily on GNU/Linux system.

      cw  reads  characters  from  an input file, or from standard input,
      and sounds each valid character as Morse code on either the system sound card,
      or the system console speaker.
      After it sounds a  character, cw  echoes it to standard output.
      The input stream can contain embedded command strings.
      These change the parameters used when sounding the Morse code.
      cw reports any errors in  embedded  commands
    '';
    homepage = "https://unixcw.sourceforge.net";
    maintainers = [ lib.maintainers.mafo ];
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
  };
}
