{
  buildGoModule,
  fetchFromGitHub,
  lib,
  testers,
  grpc-gateway,
}:

buildGoModule rec {
  pname = "grpc-gateway";
  version = "2.26.3";

  src = fetchFromGitHub {
    owner = "grpc-ecosystem";
    repo = "grpc-gateway";
    tag = "v${version}";
    sha256 = "sha256-e/TPCli2wXyzEpn84hZdtVaAmXJK+d0vMRLilXohiN8=";
  };

  vendorHash = "sha256-Des02yenoa6am0xIqto7xlOWHh44F5EBVEhi9t+v644=";

  ldflags = [
    "-X=main.version=${version}"
    "-X=main.date=1970-01-01T00:00:00Z"
    "-X=main.commit=${version}"
  ];

  passthru.tests = {
    version = testers.testVersion {
      package = grpc-gateway;
      command = "protoc-gen-grpc-gateway --version";
      version = "Version ${version}, commit ${version}, built at 1970-01-01T00:00:00Z";
    };
    openapiv2Version = testers.testVersion {
      package = grpc-gateway;
      command = "protoc-gen-openapiv2 --version";
      version = "Version ${version}, commit ${version}, built at 1970-01-01T00:00:00Z";
    };
  };

  meta = with lib; {
    description = "A gRPC to JSON proxy generator plugin for Google Protocol Buffers";
    longDescription = ''
      This is a plugin for the Google Protocol Buffers compiler (protoc). It reads
      protobuf service definitions and generates a reverse-proxy server which
      translates a RESTful HTTP API into gRPC. This server is generated according to
      the google.api.http annotations in the protobuf service definitions.
    '';
    homepage = "https://github.com/grpc-ecosystem/grpc-gateway";
    license = licenses.bsd3;
    maintainers = with maintainers; [ happyalu ];
  };
}
