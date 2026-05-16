# this is only needed because the CLI is outdated in the nixpkgs at the time of writing this
{ pkgs, system }:
let
  version = "0.43.84";
  platform =
    {
      x86_64-linux = {
        suffix = "linux_amd64";
        hash = "sha256-ZKRxVQg8e4BC3mTmfu5WKb+JSQPBAvcjn2nH7ZP9v8U=";
      };
      aarch64-linux = {
        suffix = "linux_arm64";
        hash = "sha256-KMNZO7FORznwAFhBkwT2/+uUdBEU78xCCNdL38TqiB8=";
      };
      x86_64-darwin = {
        suffix = "darwin_amd64";
        hash = "sha256-cs69f68eU6imP6MAfOMllhaha2XbJiBFCY8yXFRBxNY=";
      };
      aarch64-darwin = {
        suffix = "darwin_arm64";
        hash = "sha256-AlfrCy1gRcjGu4dIntDMqJSDMdnU92hJiBstUVtBKMY=";
      };
    }."${system}" or (throw "Unsupported system: ${system}");
  name = "cli_${version}_${platform.suffix}.tar.gz";
in
pkgs.stdenv.mkDerivation (finalAttrs: {
  pname = "infisical";
  inherit version;

  src = pkgs.fetchurl {
    inherit name;
    url = "https://github.com/Infisical/cli/releases/download/v${version}/${name}";
    hash = platform.hash;
  };

  nativeBuildInputs = [ pkgs.installShellFiles ];

  doCheck = true;
  dontConfigure = true;
  dontStrip = true;

  sourceRoot = ".";
  buildPhase = "chmod +x ./infisical";
  checkPhase = "./infisical --version";
  installPhase = ''
    mkdir -p $out/bin $out/share/completions $out/share/man
    cp infisical $out/bin/
    cp completions/* $out/share/completions/
    cp manpages/* $out/share/man/
  '';
  postInstall = ''
    installManPage share/man/infisical.1.gz
    installShellCompletion share/completions/infisical.{bash,fish,zsh}
  '';

  passthru.tests.version = pkgs.testers.testVersion {
    package = finalAttrs.finalPackage;
  };

  meta = with pkgs.lib; {
    description = "Official Infisical CLI";
    homepage = "https://infisical.com";
    changelog = "https://github.com/Infisical/cli/releases/tag/v${version}";
    license = licenses.mit;
    mainProgram = "infisical";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  };
})
