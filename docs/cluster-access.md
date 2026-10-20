# Administer the cluster

## Open the administrative interfaces

Use the protected public hostnames:

- [Nomad](https://nomad.4w4y.run)
- [Vault](https://vault.4w4y.run)
- [Consul](https://consul.4w4y.run)

Sign in with the configured operator identity, then use the service's native
login. Access sessions last eight hours. MFA remains optional.

Terraform manages these Access applications and their policies in the existing
Cloudflare module. Administrative tunnel origins use verified HTTPS and enforce
the matching application's audience. The Consul route blocks
`/v1/agent/connect/ca/leaf` and its children.

## Run Terraform through Access

Entering the live environment loads operator credentials from Infisical's
`/terraform` folder. The providers attach `CF-Access-Client-Id` and
`CF-Access-Client-Secret` using `CF_ACCESS_CLIENT_ID` and
`CF_ACCESS_CLIENT_SECRET`. Native Nomad, Consul, and Vault tokens still authorize
the underlying API operations.

```sh
zsh -ilc 'cd /home/adachi/infrastructure/terraform/live/interserver-run4w4y/nomad && terragrunt plan'
zsh -ilc 'cd /home/adachi/infrastructure/terraform/live/interserver-run4w4y/consul && terragrunt plan'
zsh -ilc 'cd /home/adachi/infrastructure/terraform/live/interserver-run4w4y/vault && terragrunt plan'
```

`NOMAD_ADDR`, `CONSUL_HTTP_ADDR`, and `VAULT_ADDR` select the public HTTPS
endpoints. Public TLS uses the system trust store. Infisical stores the public
cluster CA as `CLUSTER_CA_BASE64` so dotenv can load it as one line. The live
Nomad input decodes that value for internal HTTPS signing-key discovery in
Consul and Vault.

Each CI repository has a dedicated Infisical project containing only
`CF_ACCESS_CLIENT_ID`, `CF_ACCESS_CLIENT_SECRET`, and its native `NOMAD_TOKEN`.
Credentials live in the `prod` environment's root folder, `/`. Each project's
GitHub OIDC identity has the built-in Viewer role and an exact subject:

| Repository | OIDC subject |
| --- | --- |
| `infrastructure` | `repo:run4w4y/infrastructure:ref:refs/heads/main` |
| `cv` | `repo:run4w4y/cv:environment:production` |

## Use native administrative CLIs

Use the independent SSH or VPN route when a native CLI needs the private APIs.
Configure the private HTTPS endpoint, its expected TLS server name, and the
service's ACL token in that session. Use the cluster CA for private TLS.

With those settings in place, inspect the cluster with the standard tools:

```sh
nomad server members
consul members
vault status
```

Keep SSH and the independent VPN available during API or firewall maintenance.
The maintained `ansible/files/cluster-mesh-guard.nft` and service unit define
the existing public mesh-port filter. `cluster-security.yml` installs those
assets. The `cluster-admin.nft` rules block public access to the native administrative
API ports while allowing loopback, Nomad/Docker bridges, and the VPN interface.
The playbook also removes the retired forwarding-only CI account and its SSH
configuration. SSH and the independent VPN remain available for recovery.

## Maintain the API certificates

Run `ansible/playbooks/cluster-certificates.yml` through the normal Ansible
environment. The playbook installs a local Ansible runtime with
`community.crypto` pinned to `2.26.0`. It places the renewal playbook and tasks
under `/etc/ansible/cluster-certificates/`.

`cluster-certificates.timer` runs daily. The service uses `flock` to prevent
overlapping renewals. The local playbook renews Nomad and Vault leaves when
fewer than 21 days remain, using the existing Consul CA and a 90-day lifetime.
The signing key remains on the server. Infisical stores the public CA as
`CLUSTER_CA_BASE64`.

The playbook checks each new certificate and key before activation. It reloads
the service, checks the served certificate and API health, and keeps the previous
generation for recovery. Vault must retain its explicit
`service_registration "consul"` configuration before a reload.

Inspect the timer and renewal log through SSH:

```sh
systemctl status cluster-certificates.timer
journalctl -u cluster-certificates.service
```

## Preserve recovery data

Keep encrypted Consul and Nomad snapshots, Vault recovery material, service
configuration, certificate keys, and application-volume backups outside Git.
`VAULT_UNSEAL_KEY` remains in the Infisical project's root folder under the
`interserver-run4w4y-0` environment.

Retain the encrypted MinIO image archive with the cluster backups. The job pins
the cached image because its former `latest` tag is unavailable. A replacement
host may need `docker image load` from the decrypted archive before Nomad can
start MinIO. The image archive does not contain MinIO data.

Preserve Paseo's local image archive and persistent volume as described in
[Paseo recovery](paseo.md#restore-the-local-image).

## Runtime pins

| Component | Version |
| --- | --- |
| Nomad | `2.0.7` |
| Consul | `2.0.4` |
| Vault | `2.2.0` |
| Traefik | `3.7.15` |
| Envoy | `1.38.6` |
| Consul CNI | `2.0.4` |
