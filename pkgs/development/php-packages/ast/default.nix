{
  buildPecl,
  lib,
  fetchFromGitHub,
}:

let
  version = "1.1.2";
in
buildPecl {
  inherit version;
  pname = "ast";

  src = fetchFromGitHub {
    owner = "nikic";
    repo = "php-ast";
    tag = "v${version}";
    sha256 = "sha256-9HP+hKcpkWmvsx335JiCVjFG+xyAMEm5dWxWC1nZPxU=";
  };

  meta = with lib; {
    changelog = "https://github.com/nikic/php-ast/releases/tag/v${version}";
    description = "Exposes the abstract syntax tree generated by PHP";
    license = licenses.bsd3;
    homepage = "https://pecl.php.net/package/ast";
    maintainers = teams.php.members;
  };
}
