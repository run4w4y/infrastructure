{
  description = "deployment tools shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    infisical-nix = {
      url = "git+ssh://git@github.com/run4w4y/infisical-nix.git";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = { self, nixpkgs, flake-utils, infisical-nix }: flake-utils.lib.eachDefaultSystem (
    system:
    let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      infisical-cli = infisical-nix.packages.${system}.infisical-cli;
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
          infisical-cli
          git-crypt
          unzip
          minio-client
        ];
      };
    }
  );
}
