{
  lib,
  amazon-cloudwatch-agent,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  nixosTests,
  stdenv,
  versionCheckHook,
}:

buildGoModule rec {
  pname = "amazon-cloudwatch-agent";
  version = "1.300053.0";

  src = fetchFromGitHub {
    owner = "aws";
    repo = "amazon-cloudwatch-agent";
    tag = "v${version}";
    hash = "sha256-YXi59OHWd3NtQSKUpa7vSfDxS1TA6F3IZX8RvfiR5Q0=";
  };

  vendorHash = "sha256-k/u5eYVFrpP3kP2ImuYUOjy0GPuw2ZswJ3Q5ztyXZN8=";

  # See the list in https://github.com/aws/amazon-cloudwatch-agent/blob/v1.300049.1/Makefile#L68-L77.
  subPackages = [
    "cmd/config-downloader"
    "cmd/config-translator"
    "cmd/amazon-cloudwatch-agent"
    # Broken since it hardcodes the package install path. See https://github.com/aws/amazon-cloudwatch-agent/issues/1319.
    # "cmd/start-amazon-cloudwatch-agent"
    "cmd/amazon-cloudwatch-agent-config-wizard"
  ];

  # See https://github.com/aws/amazon-cloudwatch-agent/blob/v1.300049.1/Makefile#L57-L64.
  #
  # Needed for "amazon-cloudwatch-agent -version" to not show "Unknown".
  postInstall = ''
    echo v${version} > $out/bin/CWAGENT_VERSION
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [ versionCheckHook ];

  versionCheckProgram = "${builtins.placeholder "out"}/bin/amazon-cloudwatch-agent";

  versionCheckProgramArg = "-version";

  passthru = {
    tests = lib.optionalAttrs stdenv.isLinux {
      inherit (nixosTests) amazon-cloudwatch-agent;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "CloudWatch Agent enables you to collect and export host-level metrics and logs on instances running Linux or Windows server";
    homepage = "https://github.com/aws/amazon-cloudwatch-agent";
    license = lib.licenses.mit;
    mainProgram = "amazon-cloudwatch-agent";
    maintainers = with lib.maintainers; [ pmw ];
  };
}
