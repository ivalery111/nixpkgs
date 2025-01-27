{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  nix-update-script,
  ncurses,
  enableSdl2 ? true,
  SDL2,
  SDL2_image,
  SDL2_sound,
  SDL2_mixer,
  SDL2_ttf,
}:
stdenv.mkDerivation rec {
  pname = "narsil";
  version = "f5ec6bd6b8013f2a2b74fc45b6f4c53744590ec5";

  src = fetchFromGitHub {
    owner = "NickMcConnell";
    repo = "NarSil";
    rev = version;
    hash = "sha256-xMY9XmFsjcucLPfwTXiC0oQ2UkWIkWCehvycesqbWn0=";
  };

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch=main" ]; };

  nativeBuildInputs = [ autoreconfHook ];
  buildInputs =
    [ ncurses ]
    ++ lib.optionals enableSdl2 [
      SDL2
      SDL2_image
      SDL2_sound
      SDL2_mixer
      SDL2_ttf
    ];

  enableParallelBuilding = true;

  configureFlags = lib.optional enableSdl2 "--enable-sdl2";

  installFlags = [ "bindir=$(out)/bin" ];

  meta = {
    homepage = "https://github.com/NickMcConnell/NarSil/";
    description = "Unofficial rewrite of Sil, a roguelike influenced by Angband";
    mainProgram = "narsil";
    changelog = "https://github.com/NickMcConnell/NarSil/releases/tag/${version}";
    longDescription = ''
      NarSil attempts to be an almost-faithful recreation of Sil 1.3.0,
      but based on the codebase of modern Angband.
    '';
    maintainers = with lib.maintainers; [
      nanotwerp
      x123
    ];
    license = lib.licenses.gpl2;
  };
}
