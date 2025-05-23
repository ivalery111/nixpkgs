{
  lib,
  stdenv,
  fwts,
  kernel,
  kernelModuleMakeFlags,
}:

stdenv.mkDerivation rec {
  pname = "fwts-efi-runtime";
  version = "${fwts.version}-${kernel.version}";

  inherit (fwts) src;

  sourceRoot = "${src.name}/efi_runtime";

  postPatch = ''
    substituteInPlace Makefile --replace \
      '/lib/modules/$(KVER)/build' \
      '${kernel.dev}/lib/modules/${kernel.modDirVersion}/build'
  '';

  nativeBuildInputs = kernel.moduleBuildDependencies;

  hardeningDisable = [ "pic" ];

  makeFlags = kernelModuleMakeFlags ++ [
    "INSTALL_MOD_PATH=${placeholder "out"}"
  ];

  meta = with lib; {
    inherit (fwts.meta) homepage license;
    description = fwts.meta.description + "(efi-runtime kernel module)";
    maintainers = with maintainers; [ dtzWill ];
    platforms = platforms.linux;
  };
}
