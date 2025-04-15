{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  callPackage,
  buildExamples ? false,
  buildTests ? false,
  buildAll ? false,
}:

# Derivation build example:
#   $ nix-build -A sobjectizer
stdenv.mkDerivation (finalAttrs: {
  pname = "sobjectizer";
  version = "5.8.4";

  src = fetchFromGitHub {
    owner = "Stiffstream";
    repo = "sobjectizer";
    rev = "48240cff83d758f0e7fc413ec408536147a374ed";
    hash = "sha256-tIqWgd6TppHfqZk3XHzhG0t+Nn8BQCTP81UD7ls67UE=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeDir = "../dev";

  cmakeFlags = lib.optionals (buildExamples) [ "-DBUILD_EXAMPLES=ON" ] ++
               lib.optionals (buildTests)    [ "-DBUILD_TESTS=ON" ] ++
               lib.optionals (buildAll)      [ "-DBUILD_ALL=ON" ];

  doCheck = buildTests || buildAll;
  checkPhase = ''
    runHook preCheck

    ctest -C Release --output-on-failure

    runHook postCheck
  '';

  # Test invocation example:
  #   $ nix-build --attr pkgs.sobjectizer.passthru.tests.ping-pong-*
  passthru = {
    tests = {
      ping-pong-static = callPackage ./tests/ping-pong-static { };
      ping-pong-shared = callPackage ./tests/ping-pong-shared { };
    };
  };

  meta = with lib; {
    homepage = "https://github.com/Stiffstream/sobjectizer/tree/master";
    changelog = "https://github.com/Stiffstream/sobjectizer/releases/tag/v.${finalAttrs.version}";
    description = "An implementation of Actor, Publish-Subscribe, and CSP models in one rather small C++ framework. With performance, quality, and stability proved by years in the production. ";
    license = licenses.bsd3;
    maintainers = [  ];
    platforms = platforms.all;
  };
})
