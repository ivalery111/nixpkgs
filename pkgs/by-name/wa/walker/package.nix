{
  lib,
  buildGoModule,
  fetchFromGitHub,
  pkg-config,
  vips,
  gobject-introspection,
  wrapGAppsHook4,
  gtk4,
  gtk4-layer-shell,
  nix-update-script,
}:

buildGoModule rec {
  pname = "walker";
  version = "0.12.19";

  src = fetchFromGitHub {
    owner = "abenz1267";
    repo = "walker";
    tag = "v${version}";
    hash = "sha256-XOOYalJ+6V/O/fhC5gEDk2m1yZ2e5DofRRIi8ETHgoQ=";
  };

  vendorHash = "sha256-6PPNVnsH1eU4fLcZpxiBoHCzN/TUUxfTfmxDsBDPDKQ=";
  subPackages = [ "cmd/walker.go" ];

  passthru.updateScript = nix-update-script { };

  nativeBuildInputs = [
    pkg-config
    gobject-introspection
    wrapGAppsHook4
  ];

  buildInputs = [
    gtk4
    vips
    gtk4-layer-shell
  ];

  meta = with lib; {
    description = "Wayland-native application runner";
    homepage = "https://github.com/abenz1267/walker";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = with maintainers; [ donovanglover ];
    mainProgram = "walker";
  };
}
