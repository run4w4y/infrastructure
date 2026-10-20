# Operate Paseo

Paseo runs on host1 as Nomad job `paseo`. Its persistent daemon and browser client
are available at [paseo.4w4y.run](https://paseo.4w4y.run). Native clients use
`wss://paseo.4w4y.run/ws`.

Local agent providers are disabled. Connect to a separate worker daemon to run
agents. Native owner authentication also permits terminal execution inside this
container, so access belongs to trusted operators.

## Access and deploy the service

The owner credential remains in Vault KV v2 mount `secret`, path `paseo/runtime`.
The job renders only `password_hash` into its configuration. Retrieve the owner
password through a trusted Vault session and keep it outside Git and endpoint
URLs.

The installed my-pi CLI connects to the remote daemon with:

```sh
paseo --host https://paseo.4w4y.run status
```

Its matching host password comes from the private
`~/.config/my-pi/paseo-hosts.json` file populated from Vault. The remote connection
uses its own host credential.

The Nomad job and template belong to `terraform/modules/nomad/jobs/paseo/`.
The Nomad module owns the state volume and `paseo-bootstrap` workload role and
policy. The Consul module owns the service defaults and the Traefik-to-Paseo
intention. Runtime configuration and resource settings remain under
`services/paseo/`.

Review changes in the existing Nomad workspace:

```sh
zsh -ilc 'cd /home/adachi/infrastructure/terraform/live/interserver-run4w4y/nomad && terragrunt plan'
```

After reviewing the full plan, run `terragrunt apply` in the same environment.
Use the operator Access credentials from Infisical's `/terraform` folder.
Apply changed Consul entries before the job.

Use a private native CLI session to inspect the deployment:

```sh
nomad job status paseo
```

For task maintenance, restart only task `paseo` in its allocation. The service's
HTTP health check uses `/api/health`. Application APIs and WebSocket connections
require the owner password. Static browser assets and the health endpoint are
public.

## Preserve the runtime settings

The job stays on host1 and uses local Docker image ID
`sha256:113a7d44e7eca18ff1447db32eb8b9da9ff7f4d189f660d2a5b43afea0123cbb`
with `force_pull = false`. This image has no published registry reference.

| Component | Pin |
| --- | --- |
| Paseo CLI, client, and protocol | `0.11.4` |
| Pi | `1.3.0` |
| nono | `0.80.0`, revision `8bb041356d48f771a221e58c98d9b1ff442e76fe` with the existing patches |
| Node | `24.19.0` |
| Document viewer | `0.3.0` |

The main task reserves 384 MiB and has a 2,304 MiB hard limit. Its Connect proxy
reserves 128 MiB. Nomad memory oversubscription is enabled and must remain
enabled for this reservation and hard-limit combination.

The daemon runs as UID and GID 65534. The persistent `paseo-state` volume holds
`/var/lib/paseo/{daemon,home,agent,repositories,cache}`. Back up this data and the
Vault credential before moving or retiring the service.

## Restore the local image

The retained host archive is
`/var/lib/nomad/paseo-bootstrap-artifacts/5b3667b0b86ed55282fdc7f926c79ee028d3112620b09c5f900d9d974fe58ed9/image.tar.gz`.
Its SHA-256 is
`5b3667b0b86ed55282fdc7f926c79ee028d3112620b09c5f900d9d974fe58ed9`.
Verify the archive checksum, then load the archive with `docker image load`
before scheduling the job on a replacement host. Check that the loaded image ID
matches the job's pin. An image archive does not contain the persistent data.

[image.nix](../services/paseo/image.nix) builds an image from the immutable Nix
paths in [runtime.json](../services/paseo/runtime.json). Those store paths must
exist on the build host or be restored from a saved closure. Build into a private
state directory:

```sh
zsh -ilc 'cd /home/adachi/infrastructure && nix build --impure --file services/paseo/image.nix --out-link /private/state/paseo-image'
```

Load the resulting archive into Docker and inspect its image ID. If a rebuild
produces a different ID, review the Nomad image input change before deployment.
Keep the retained archive available for recovery of the current pin.
