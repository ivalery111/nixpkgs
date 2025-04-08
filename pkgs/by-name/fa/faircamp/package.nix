{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitea,
  makeWrapper,
  pkg-config,
  glib,
  libopus,
  vips,
  ffmpeg,
  callPackage,
  darwin,
  testers,
  faircamp,
}:

rustPlatform.buildRustPackage rec {
  pname = "faircamp";
  version = "1.2.0";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "simonrepp";
    repo = "faircamp";
    rev = version;
    hash = "sha256-InBPQk8dIwsCfvo24/0ggK/tipHaC0owPbZtrrIT/FY=";
  };

  useFetchCargoVendor = true;

  cargoHash = "sha256-f+RFjBiChLAEk0Azh2wqXmOlDNl3221MYUVVbCisg0c=";

  buildFeatures = [ "libvips" ];

  nativeBuildInputs = [
    makeWrapper
    pkg-config
  ];

  buildInputs =
    [
      glib
      libopus
      vips
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      darwin.apple_sdk.frameworks.CoreServices
    ];

  postInstall = ''
    wrapProgram $out/bin/faircamp \
      --prefix PATH : ${lib.makeBinPath [ ffmpeg ]}
  '';

  passthru.tests = {
    wav = callPackage ./test-wav.nix { };
    version = testers.testVersion { package = faircamp; };
  };

  meta = with lib; {
    description = "Self-hostable, statically generated bandcamp alternative";
    mainProgram = "faircamp";
    longDescription = ''
      Faircamp takes a directory on your disk - your Catalog - and from it
      produces a fancy-looking (and technically simple and completely static)
      website, which presents your music in a way similar to how popular
      commercial service bandcamp does it.

      You can upload the files faircamp generates to any webspace - no database
      and no programming language support (PHP or such) is required. If your
      webspace supports SSH access, faircamp can be configured to upload your
      website for you automatically, otherwise you can use FTP or whichever
      means you prefer to do that manually.
    '';
    homepage = "https://simonrepp.com/faircamp/";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ fgaz ];
    platforms = platforms.all;
  };
}
