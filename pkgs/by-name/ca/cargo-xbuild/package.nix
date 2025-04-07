{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "cargo-xbuild";
  version = "0.6.6";

  src = fetchFromGitHub {
    owner = "rust-osdev";
    repo = pname;
    tag = "v${version}";
    hash = "sha256-29rCjmzxxIjR5nBN2J3xxP+r8NnPIJV90FkSQQEBbo4=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-8ceL4Ntb+P+BvLqlnSxKcyZREckyWAKDhxR6prjaxHM=";

  meta = with lib; {
    description = "Automatically cross-compiles the sysroot crates core, compiler_builtins, and alloc";
    homepage = "https://github.com/rust-osdev/cargo-xbuild";
    license = with licenses; [
      mit
      asl20
    ];
    maintainers = with maintainers; [
      johntitor
      xrelkd
    ];
  };
}
