{
  lib,
  stdenv,
  fetchFromGitHub,
  python3Packages,
  unstableGitUpdater,
}:

python3Packages.buildPythonPackage {
  pname = "edl";
  version = "3.52.1-unstable-2025-03-23";

  src = fetchFromGitHub {
    owner = "bkerler";
    repo = "edl";
    rev = "9acf74d0ccca4aff85c8698cdd49ad964128e7d1";
    fetchSubmodules = true;
    hash = "sha256-mdA3a3VS0oDt1Y4n/KPzXUVq/ldyvpJjMtkv9i5w1Jg=";
  };

  propagatedBuildInputs = with python3Packages; [
    pyusb
    pyserial
    docopt
    pylzma
    pycryptodome
    lxml
    colorama
    capstone
    keystone-engine
  ];

  # No tests set up
  doCheck = false;
  # EDL loaders are ELFs but shouldn't be touched, rest is Python anyways
  dontStrip = true;

  # edl has a spurious dependency on "usb" which has nothing to do with the
  # project and was probably added by accident trying to add pyusb
  postPatch = ''
    sed -i '/'usb'/d' setup.py
  '';

  postInstall = ''
    mkdir -p $out/etc/udev/rules.d
    cp $src/Drivers/51-edl.rules $out/etc/udev/rules.d/51-edl.rules
  '';

  passthru.updateScript = unstableGitUpdater { };

  meta = with lib; {
    homepage = "https://github.com/bkerler/edl";
    description = "Qualcomm EDL tool (Sahara / Firehose / Diag)";
    # See https://github.com/NixOS/nixpkgs/issues/348931
    license = licenses.unfree;
    maintainers = with maintainers; [
      lorenz
      xddxdd
    ];
    # Case-sensitive files in 'Loader' submodule
    broken = stdenv.hostPlatform.isDarwin;
  };
}
