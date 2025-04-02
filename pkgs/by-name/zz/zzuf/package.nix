{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  pkg-config,
  autoreconfHook,
}:

stdenv.mkDerivation rec {
  pname = "zzuf";
  version = "0.15";

  src = fetchFromGitHub {
    owner = "samhocevar";
    repo = "zzuf";
    rev = "v${version}";
    sha256 = "0li1s11xf32dafxq1jbnc8c63313hy9ry09dja2rymk9mza4x2n9";
  };

  patches = [
    # fix build with gcc14
    # https://src.fedoraproject.org/rpms/zzuf/c/998c7e5e632ea4c635a53437a01bfb48cbd744ac
    (fetchpatch {
      url = "https://src.fedoraproject.org/rpms/zzuf/raw/998c7e5e632ea4c635a53437a01bfb48cbd744ac/f/zzuf-zzat-c99.patch";
      hash = "sha256-pQQzwsIjKg+9g+dnhFGn2PUlxHlQ5Mj+e4a1D1k2oEo=";
    })
    # https://src.fedoraproject.org/rpms/zzuf/c/ca7e406989e7ff461600084f2277ad15a8c00058
    ./zzuf-glibc.patch
  ];

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
  ];

  meta = with lib; {
    description = "Transparent application input fuzzer";
    homepage = "http://caca.zoy.org/wiki/zzuf";
    license = licenses.wtfpl;
    platforms = platforms.linux;
    maintainers = with maintainers; [ lihop ];
  };
}
