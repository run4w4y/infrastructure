{
  description = "deployment tools shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: flake-utils.lib.eachDefaultSystem (
    system:
    let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    with pkgs;
    {
      devShells.default = mkShell {
        venvDir = ".venv";
        packages = with pkgs;
          [ python311 ] ++
          (with pkgs.python311Packages; [
            pip
            venvShellHook
            netaddr
            jmespath
          ]);
        buildInputs = [
          nomad
          consul
          nomad-pack
          terraform
          terragrunt
          ansible
          vault
          unzip
          minio-client
        ];
      };
    }
  );
}
