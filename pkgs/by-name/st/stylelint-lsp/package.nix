{
  fetchFromGitHub,
  lib,
  nodejs,
  pnpm_9,
  stdenvNoCC,
  nix-update-script,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "stylelint-lsp";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "bmatcuk";
    repo = "stylelint-lsp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-mzhY6MKkXb1jFYZvs/VkGipBjBfUY3GukICb9qVQI80=";
  };

  buildInputs = [
    nodejs
  ];

  nativeBuildInputs = [
    pnpm_9.configHook
  ];

  pnpmDeps = pnpm_9.fetchDeps {
    inherit (finalAttrs) pname version src;
    hash = "sha256-PVA6sXbiuxqvi9u3sPoeVIJSSpSbFQHQQnTFO3w31WE=";
  };

  buildPhase = ''
    runHook preBuild

    pnpm build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,lib/${finalAttrs.pname}}
    mv {dist,node_modules} $out/lib/${finalAttrs.pname}
    chmod a+x $out/lib/${finalAttrs.pname}/dist/index.js
    ln -s $out/lib/${finalAttrs.pname}/dist/index.js $out/bin/stylelint-lsp

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "A stylelint Language Server";
    homepage = "https://github.com/bmatcuk/stylelint-lsp";
    license = lib.licenses.mit;
    mainProgram = "stylelint-lsp";
    maintainers = with lib.maintainers; [
      gepbird
    ];
    platforms = lib.platforms.unix;
  };
})
