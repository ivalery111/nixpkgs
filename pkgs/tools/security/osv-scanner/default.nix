{ lib
, buildGoModule
, fetchFromGitHub
, testers
, osv-scanner
}:

buildGoModule rec {
  pname = "osv-scanner";
  version = "1.8.4";

  src = fetchFromGitHub {
    owner = "google";
    repo = "osv-scanner";
    rev = "refs/tags/v${version}";
    hash = "sha256-e1a21zBxMa89PuNXPbeTpY3mHeO0TvxcoHcWRPUYwsM=";
  };

  vendorHash = "sha256-ZmWgupPHZhv+MmNfFmuU1Cjin5liNcgkzdxw3Sf614c=";

  subPackages = [
    "cmd/osv-scanner"
  ];

  ldflags = [
    "-s"
    "-w"
    "-X=github.com/google/osv-scanner/internal/version.OSVVersion=${version}"
    "-X=main.commit=n/a"
    "-X=main.date=1970-01-01T00:00:00Z"
  ];

  # Tests require network connectivity to query https://api.osv.dev.
  doCheck = false;

  passthru.tests.version = testers.testVersion {
    package = osv-scanner;
  };

  meta = with lib; {
    description = "Vulnerability scanner written in Go which uses the data provided by https://osv.dev";
    mainProgram = "osv-scanner";
    homepage = "https://github.com/google/osv-scanner";
    changelog = "https://github.com/google/osv-scanner/releases/tag/v${version}";
    license = licenses.asl20;
    maintainers = with maintainers; [ stehessel urandom ];
  };
}
