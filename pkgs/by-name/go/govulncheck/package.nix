{
  lib,
  buildGoModule,
  fetchFromGitHub,
  replaceVars,
}:

buildGoModule rec {
  pname = "govulncheck";
  version = "1.1.3";

  src = fetchFromGitHub {
    owner = "golang";
    repo = "vuln";
    rev = "refs/tags/v${version}";
    hash = "sha256-ydJ8AeoCnLls6dXxjI05+THEqPPdJqtAsKTriTIK9Uc=";
  };

  patches = [
    # patch in version information
    (replaceVars ./version.patch {
      inherit version;
    })
  ];

  vendorHash = "sha256-jESQV4Na4Hooxxd0RL96GHkA7Exddco5izjnhfH6xTg=";

  subPackages = [
    "cmd/govulncheck"
  ];

  # Vendoring breaks tests
  doCheck = false;

  ldflags = [
    "-s"
    "-w"
  ];

  meta = with lib; {
    homepage = "https://pkg.go.dev/golang.org/x/vuln/cmd/govulncheck";
    downloadPage = "https://github.com/golang/vuln";
    changelog = "https://github.com/golang/vuln/releases/tag/v${version}";
    description = "Database client and tools for the Go vulnerability database, also known as vuln";
    mainProgram = "govulncheck";
    longDescription = ''
      Govulncheck reports known vulnerabilities that affect Go code. It uses
      static analysis of source code or a binary's symbol table to narrow down
      reports to only those that could affect the application.

      By default, govulncheck makes requests to the Go vulnerability database at
      https://vuln.go.dev. Requests to the vulnerability database contain only
      module paths, not code or other properties of your program. See
      https://vuln.go.dev/privacy.html for more. Set the GOVULNDB environment
      variable to specify a different database, which must implement the
      specification at https://go.dev/security/vuln/database.

      Govulncheck looks for vulnerabilities in Go programs using a specific
      build configuration. For analyzing source code, that configuration is the
      operating system, architecture, and Go version specified by GOOS, GOARCH,
      and the “go” command found on the PATH. For binaries, the build
      configuration is the one used to build the binary. Note that different
      build configurations may have different known vulnerabilities. For
      example, a dependency with a Windows-specific vulnerability will not be
      reported for a Linux build.
    '';
    license = with licenses; [ bsd3 ];
    maintainers = with maintainers; [
      jk
      SuperSandro2000
    ];
  };
}
