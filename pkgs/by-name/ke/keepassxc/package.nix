{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  libsForQt5,

  apple-sdk_15,
  asciidoctor,
  botan3,
  curl,
  darwinMinVersionHook,
  libXi,
  libXtst,
  libargon2,
  libusb1,
  minizip,
  nix-update-script,
  pcsclite,
  pkg-config,
  qrencode,
  readline,
  wrapGAppsHook3,
  zlib,

  darwin,

  withKeePassBrowser ? true,
  withKeePassBrowserPasskeys ? true,
  withKeePassFDOSecrets ? true,
  withKeePassKeeShare ? true,
  withKeePassNetworking ? true,
  withKeePassSSHAgent ? true,
  withKeePassTouchID ? true,
  withKeePassX11 ? true,
  withKeePassYubiKey ? true,

  nixosTests,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "keepassxc";
  version = "2.7.10";

  src = fetchFromGitHub {
    owner = "keepassxreboot";
    repo = "keepassxc";
    tag = finalAttrs.version;
    hash = "sha256-FBoqCYNM/leN+w4aV0AJMx/G0bjHbI9KVWrnmq3NfaI=";
  };

  env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.cc.isClang (toString [
    "-Wno-old-style-cast"
    "-Wno-error"
    "-D__BIG_ENDIAN__=${if stdenv.hostPlatform.isBigEndian then "1" else "0"}"
  ]);

  NIX_LDFLAGS = lib.optionalString stdenv.hostPlatform.isDarwin "-rpath ${libargon2}/lib";

  patches = [ ./darwin.patch ];

  cmakeFlags =
    [
      (lib.cmakeFeature "KEEPASSXC_BUILD_TYPE" "Release")
      (lib.cmakeBool "WITH_GUI_TESTS" true)
      (lib.cmakeBool "WITH_XC_UPDATECHECK" false)
    ]
    ++ lib.optionals (!withKeePassX11) [
      (lib.cmakeBool "WITH_XC_X11" false)
    ]
    ++ lib.optionals (withKeePassFDOSecrets && stdenv.hostPlatform.isLinux) [
      (lib.cmakeBool "WITH_XC_FDOSECRETS" true)
    ]
    ++ lib.optionals (withKeePassYubiKey && stdenv.hostPlatform.isLinux) [
      (lib.cmakeBool "WITH_XC_YUBIKEY" true)
    ]
    ++ lib.optionals withKeePassBrowser [
      (lib.cmakeBool "WITH_XC_BROWSER" true)
    ]
    ++ lib.optionals withKeePassBrowserPasskeys [
      (lib.cmakeBool "WITH_XC_BROWSER_PASSKEYS" true)
    ]
    ++ lib.optionals withKeePassKeeShare [
      (lib.cmakeBool "WITH_XC_KEESHARE" true)
    ]
    ++ lib.optionals withKeePassNetworking [
      (lib.cmakeBool "WITH_XC_NETWORKING" true)
    ]
    ++ lib.optionals withKeePassSSHAgent [
      (lib.cmakeBool "WITH_XC_SSHAGENT" true)
    ];

  doCheck = true;
  checkPhase = ''
    runHook preCheck

    export LC_ALL="en_US.UTF-8"
    export QT_QPA_PLATFORM=offscreen
    export QT_PLUGIN_PATH="${libsForQt5.qtbase.bin}/${libsForQt5.qtbase.qtPluginPrefix}"
    # testcli, testgui and testkdbx4 are flaky - skip them all
    # testautotype on darwin throws "QWidget: Cannot create a QWidget without QApplication"
    make test ARGS+="-E 'testcli|testgui${lib.optionalString stdenv.hostPlatform.isDarwin "|testautotype|testkdbx4"}' --output-on-failure"

    runHook postCheck
  '';

  nativeBuildInputs = [
    asciidoctor
    cmake
    libsForQt5.wrapQtAppsHook
    libsForQt5.qttools
    pkg-config
  ] ++ lib.optional (!stdenv.hostPlatform.isDarwin) wrapGAppsHook3;

  dontWrapGApps = true;
  preFixup =
    ''
      qtWrapperArgs+=("''${gappsWrapperArgs[@]}")
    ''
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
      wrapQtApp "$out/Applications/KeePassXC.app/Contents/MacOS/KeePassXC"
    '';

  postInstall = lib.concatLines [
    (lib.optionalString stdenv.hostPlatform.isDarwin ''
      mkdir -p "$out/bin"
      for program in keepassxc-cli keepassxc-proxy; do
        ln -s "$out/Applications/KeePassXC.app/Contents/MacOS/$program" "$out/bin/$program"
      done
    '')

    # See https://github.com/keepassxreboot/keepassxc/blob/cd7a53abbbb81e468efb33eb56eefc12739969b8/src/browser/NativeMessageInstaller.cpp#L317
    (lib.optionalString withKeePassBrowser ''
      mkdir -p "$out/lib/mozilla/native-messaging-hosts"
      substituteAll "${./firefox-native-messaging-host.json}" "$out/lib/mozilla/native-messaging-hosts/org.keepassxc.keepassxc_browser.json"
    '')
  ];

  buildInputs =
    [
      botan3
      curl
      libXi
      libXtst
      libargon2
      libsForQt5.kio
      libsForQt5.qtbase
      libsForQt5.qtsvg
      minizip
      pcsclite
      qrencode
      readline
      zlib
    ]
    ++ lib.optionals (stdenv.hostPlatform.isDarwin && withKeePassTouchID) [
      darwin.apple_sdk_11_0.frameworks.LocalAuthentication
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      libsForQt5.qtmacextras

      apple-sdk_15
      # ScreenCaptureKit, required by livekit, is only available on 12.3 and up:
      # https://developer.apple.com/documentation/screencapturekit
      (darwinMinVersionHook "12.3")
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      libusb1
    ]
    ++ lib.optionals withKeePassX11 [
      libsForQt5.qtx11extras
    ];

  passthru = {
    tests = {
      inherit (nixosTests) keepassxc;
    };
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Offline password manager with many features";
    longDescription = ''
      A community fork of KeePassX, which is itself a port of KeePass Password Safe.
      The goal is to extend and improve KeePassX with new features and bugfixes,
      to provide a feature-rich, fully cross-platform and modern open-source password manager.
      Accessible via native cross-platform GUI, CLI, has browser integration
      using the KeePassXC Browser Extension (https://github.com/keepassxreboot/keepassxc-browser)
    '';
    homepage = "https://keepassxc.org/";
    changelog = "https://github.com/keepassxreboot/keepassxc/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.gpl2Plus;
    mainProgram = "keepassxc";
    maintainers = with lib.maintainers; [
      blankparticle
      sigmasquadron
    ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
