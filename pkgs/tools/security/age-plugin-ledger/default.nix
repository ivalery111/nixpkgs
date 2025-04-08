{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  libusb1,
  openssl,
  rage,
  AppKit,
}:

rustPlatform.buildRustPackage rec {
  pname = "age-plugin-ledger";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "Ledger-Donjon";
    repo = "age-plugin-ledger";
    rev = "v${version}";
    hash = "sha256-g5GbWXhaGEafiM3qkGlRXHcOzPZl2pbDWEBPg4gQWcg=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-zR7gJNIqno50bQo0kondCxEC0ZgssqXNqACF6fnLDrc=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libusb1
    openssl
  ] ++ lib.optional stdenv.hostPlatform.isDarwin AppKit;

  nativeCheckInputs = [
    rage
  ];

  meta = with lib; {
    description = "Ledger Nano plugin for age";
    mainProgram = "age-plugin-ledger";
    homepage = "https://github.com/Ledger-Donjon/age-plugin-ledger";
    license = with licenses; [
      mit
      asl20
    ];
    maintainers = with maintainers; [ erdnaxe ];
  };
}
