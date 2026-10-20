{ pkgs ? import (builtins.getFlake (toString ../..)).inputs.nixpkgs {
    system = "x86_64-linux";
    config.allowUnfree = true;
  }
}:
let
  paths = builtins.fromJSON (builtins.readFile ./runtime.json);
  runtime = builtins.storePath paths.runtime;
  resources = builtins.storePath paths.resources;
  documents = builtins.storePath paths.documents;
  node = builtins.storePath (builtins.dirOf (builtins.dirOf paths.node));
  nono = builtins.storePath (builtins.dirOf (builtins.dirOf paths.nono));
  enforcement = builtins.storePath paths.enforcement;
  profile = builtins.storePath paths.profile;
  instructions = builtins.storePath paths.instructions;
  manifest = pkgs.writeText "paseo-bootstrap-runtime.json" (builtins.toJSON {
    inherit runtime resources documents enforcement profile instructions;
    node = "${node}/bin/node";
    nono = "${nono}/bin/nono";
  });
  root = pkgs.runCommand "paseo-bootstrap-root" {} ''
    mkdir -p "$out/app" "$out/etc" "$out/tmp" "$out/var/lib/paseo"
    cp ${./entry.mjs} "$out/app/entry.mjs"
    cp ${manifest} "$out/app/runtime.json"
    printf 'root:x:0:0:root:/root:/bin/sh\npaseo:x:65534:65534:Paseo:/var/lib/paseo/home:/bin/sh\n' > "$out/etc/passwd"
    printf 'root:x:0:\npaseo:x:65534:\n' > "$out/etc/group"
    cat > "$out/app/local-execution-disabled" <<'SH'
    #!${pkgs.runtimeShell}
    echo 'Local agent execution is disabled on the bootstrap server; connect to a qualified worker daemon.' >&2
    exit 1
    SH
    chmod 0755 "$out/app/local-execution-disabled"
    chmod 1777 "$out/tmp"
  '';
in pkgs.dockerTools.buildLayeredImage {
  name = "paseo-bootstrap";
  tag = "0.11.4-8k94zsw";
  contents = [ root pkgs.cacert pkgs.coreutils pkgs.bash ];
  config = {
    Entrypoint = [ "${node}/bin/node" "/app/entry.mjs" ];
    User = "65534:65534";
    WorkingDir = "/var/lib/paseo";
    Env = [
      "HOME=/var/lib/paseo/home"
      "MY_PI_PASEO_HOME=/var/lib/paseo/daemon"
      "XDG_CACHE_HOME=/var/lib/paseo/cache"
      "PATH=${node}/bin:${pkgs.coreutils}/bin:${pkgs.bash}/bin"
      "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
      "NODE_EXTRA_CA_CERTS=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
    ];
    Labels = {
      "org.opencontainers.image.title" = "Pinned Paseo bootstrap with local providers disabled";
      "org.opencontainers.image.version" = "0.11.4";
      "run4w4y.paseo.role" = "bootstrap-no-providers";
    };
  };
}
