{
  lib,
  stdenv,
  fetchurl,
  fetchzip,
  makeWrapper,
  makeDesktopItem,
  zlib,
  glib,
  libpng,
  freetype,
  openssl,
  xorg,
  fontconfig,
  qt5,
  libsForQt5,
  xkeyboard_config,
  alsa-lib,
  libpulseaudio ? null,
  libredirect,
  which,
  perl,
  libcxx,
  autoPatchelfHook,
}:

let

  arch = "amd64";

  desktopItem = makeDesktopItem {
    name = "teamspeak";
    exec = "ts3client";
    icon = "teamspeak";
    comment = "The TeamSpeak voice communication tool";
    desktopName = "TeamSpeak";
    genericName = "TeamSpeak";
    categories = [ "Network" ];
  };
in

stdenv.mkDerivation rec {
  pname = "teamspeak-client";

  version = "3.6.2";

  src = fetchurl {
    url = "https://files.teamspeak-services.com/releases/client/${version}/TeamSpeak3-Client-linux_${arch}-${version}.run";
    hash = "sha256-WfEQQ4lxoj+QSnAOfdCoEc+Z1Oa5dbo6pFli1DsAZCI=";
  };

  # grab the plugin sdk for the desktop icon
  pluginsdk = fetchzip {
    url = "https://files.teamspeak-services.com/releases/sdk/3.3.1/ts_sdk_3.3.1.zip";
    hash = "sha256-wx4pBZHpFPoNvEe4xYE80KnXGVda9XcX35ho4R8QxrQ=";
  };

  nativeBuildInputs = [
    makeWrapper
    which
    perl # Installer script needs `shasum`
    qt5.wrapQtAppsHook
    autoPatchelfHook
  ];

  buildInputs = [
    zlib
    glib
    libpng
    freetype
    xorg.libSM
    xorg.libICE
    xorg.libXrender
    openssl
    xorg.libXrandr
    xorg.libXfixes
    xorg.libXcursor
    xorg.libXinerama
    xorg.libxcb
    fontconfig
    xorg.libXext
    xorg.libX11
    alsa-lib
    libpulseaudio
    libsForQt5.quazip
    libcxx
    libredirect
  ] ++ (with qt5; [
    qtbase
    qtwebengine
    qtwebchannel
    qtsvg
    qtwebsockets
  ]);

  # This just runs the installer script. If it gets stuck at something like
  # ++ exec
  # + PAGER_PATH=
  # it's looking for a dependency and didn't find it. Check the script and make sure the dep is in nativeBuildInputs.
  unpackPhase = ''
    runHook preUnpack

    echo -e '\ny' | PAGER=cat sh -xe $src

    mv TeamSpeak3-Client-linux_${arch}/* .

    runHook postUnpack
  '';

  patchPhase = ''
    runHook prePatch

    # Delete unecessary libraries - these are provided by nixos.
    find . -\( -name '*.so' -or -name '*.so.*' -\) -print0 | xargs -0 rm # I hate find.

    rm QtWebEngineProcess
    rm qt.conf

    mv ts3client_linux_${arch} ts3client

    # Our libquazip's so name has this suffix and there is no symlink
    patchelf --replace-needed libquazip.so libquazip1-qt5.so ts3client error_report

    runHook postPatch
  '';

  dontConfigure = true;
  dontBuild = true;

  installPhase =
    ''
      runHook preInstall

      # Install files.
      mkdir -p $out/lib/teamspeak
      mv * $out/lib/teamspeak/

      # Make a desktop item
      mkdir -p $out/share/applications/ $out/share/icons/hicolor/64x64/apps/
      cp ${pluginsdk}/doc/_static/logo.png $out/share/icons/hicolor/64x64/apps/teamspeak.png
      cp ${desktopItem}/share/applications/* $out/share/applications/

      # Make a symlink to the binary from bin.
      mkdir -p $out/bin/
      ln -s $out/lib/teamspeak/ts3client $out/bin/ts3client

      runHook postInstall
    '';

  preFixup =
    ''
      wrapProgram $out/bin/ts3client \
    '' # wayland is currently broken, remove when TS3 fixes that
    + ''
      --set QT_QPA_PLATFORM xcb \
      --set NIX_REDIRECTS /usr/share/X11/xkb=${xkeyboard_config}/share/X11/xkb
    '';

  meta = with lib; {
    description = "TeamSpeak voice communication tool";
    homepage = "https://teamspeak.com/";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = {
      # See distribution-permit.txt for a confirmation that nixpkgs is allowed to distribute TeamSpeak.
      fullName = "Teamspeak client license";
      url = "https://www.teamspeak.com/en/privacy-and-terms/";
      free = false;
    };
    maintainers = with maintainers; [
      lhvwb
      lukegb
      atemu
    ];
    mainProgram = "ts3client";
    platforms = [ "x86_64-linux" ];
  };
}
