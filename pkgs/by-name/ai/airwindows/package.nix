{
  stdenv,
  fetchFromGitHub,
  lib,
  cmake,
  nix-update-script,
  vst2-sdk,
}:
stdenv.mkDerivation {
  pname = "airwindows";
  version = "0-unstable-2025-04-06";

  src = fetchFromGitHub {
    owner = "airwindows";
    repo = "airwindows";
    rev = "d109d6b9948449a883a9694d3f5aa8702a57f56b";
    hash = "sha256-4yXcPedz5wYqAiLyF5Cgc/DH4jjfJGSLv4qDyIJW4x0=";
  };

  # we patch helpers because honestly im spooked out by where those variables
  # came from.
  prePatch = ''
    mkdir -p plugins/LinuxVST/include
    ln -s ${vst2-sdk} plugins/LinuxVST/include/vstsdk
  '';

  patches = [
    ./cmakelists-and-helper.patch
  ];

  # we are building for linux, so we go to linux
  preConfigure = ''
    cd plugins/LinuxVST
  '';

  cmakeBuildType = "Release";

  cmakeFlags = [ ];

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    vst2-sdk
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/vst/airwindows
    find "$PWD" -type f -name "*.so" -exec install -Dm755 {} $out/lib/vst/airwindows \;

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "All Airwindows VST Plugins";
    homepage = "https://airwindows.com/";
    platforms = lib.platforms.linux;
    license = [
      lib.licenses.mit
    ];
    maintainers = [ lib.maintainers.l1npengtul ];
  };
}
