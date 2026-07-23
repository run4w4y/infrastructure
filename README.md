# infrastructure
My server infrastructure

# Shell and secrets

The root shell is managed by `direnv` and the Nix flake. Terraform live environments can additionally load runtime variables from Infisical through `infisical export`.

Set the appropriate `INFISICAL_PROJECT_ID` in the root `.envrc`. For the deployment targets, there are additional variables that have to be set in their respective `.envrc` files. You may refer to existing environments under `/terraform/live` for setup examples.

For `terraform/live/interserver-run4w4y`, entering the directory loads `/terraform` from the configured Infisical environment when the CLI is authenticated. Ansible intentionally stays explicit; run playbooks through `infisical run --projectId="$INFISICAL_PROJECT_ID" --env="$INFISICAL_ENV" --path=/ansible -- ...`.

# Terraform and state management

I am using HCP for TF state management in `terraform/live/interserver-run4w4y`. Run `terraform login` to be able to access the state. Refer to `.envrc` and `terragrunt.hcl` files for adjusting the setup.

The HCP workspaces use local execution because their provider credentials are
injected from Infisical by the live directory's `direnv` setup. In particular,
keep `interserver-run4w4y-nomad` in local execution mode; remote execution does
not receive the Nomad, Consul, or Vault tokens.

# Step by step deployment
1. Run the Consul deployment playbook.
2. Run the Consul Terraform
3. Run the Vault Ansible playbook
4. Run the Vault Terraform
5. Run the Nomad Ansible playbook
6. Run the Cloudflare Terraform
6. Run the Nomad Terraform

## CV runtime foundations

The shared infrastructure provisions the CV application's durable tenancy while
the CV repository owns application images, Nomad Packs, database migrations and
the Terraform-managed JetStream stream/consumer definitions.

Provision the foundations in this order:

1. `vault`: create only service bootstrap credentials, including
   `secret/data/nats/root-credentials`.
2. `postgres`: create the protected `cv_registry` database and distinct
   registry, listing-checker, and PDF-worker roles and credentials.
3. `minio`: create the protected `cv-objects` and `cv-facts` buckets and their
   least-privilege identities, including the dedicated PDF-worker user.
4. `nats`: create distinct registry, listing-checker, and PDF-worker client
   credentials under their owning Nomad job paths. These runtime users can
   publish or consume only; they cannot manage JetStream topology.
5. `consul`: install intentions for `cv-registry`, `cv-web`,
   `cv-pdf-worker`, NATS, and the private Chromium CDP service.
6. `nomad`: deploy the persistent single-node NATS JetStream service and the
   generic headless Chromium service. The NATS job reads only its server
   authorization record under `secret/data/nats`; the record contains hashes
   rather than duplicated plaintext client passwords.

The CV repository owns the `cv-listing-checker` periodic Nomad Pack. This
repository grants that job a PostgreSQL Connect intention and publishes
restricted PostgreSQL and NATS credentials under `secret/data/cv-listing-checker`.
The runtime role can select, insert, and update registry tables, but cannot
delete rows or create schema objects. The PDF worker likewise has distinct
PostgreSQL, MinIO, and NATS identities under `secret/data/cv-pdf-worker`.

The PostgreSQL service uses a transparent mesh proxy, so its dynamic Nomad host
port intentionally rejects direct, unauthenticated connections. Start a local
Connect upstream with the already-allowed operator identity, then point the
PostgreSQL provider at it:

```sh
consul connect proxy -service operator-root -upstream postgres:15432

cd terraform/live/interserver-run4w4y/postgres
POSTGRES_ADDRESS=127.0.0.1 POSTGRES_PORT=15432 terragrunt plan
```

The Nomad module explicitly reserves 50 MHz, 64 MiB soft memory and 128 MiB
maximum memory for every Envoy sidecar. Nomad's implicit defaults are 250 MHz
and 128 MiB, which consume too much of this single-node cluster's CPU budget.

Roll the existing sidecar change out one job at a time and check allocation
health between applies:

```sh
cd terraform/live/interserver-run4w4y/nomad
terragrunt apply -target=module.minio
terragrunt apply -target=module.postgres
terragrunt apply -target=module.ente_museum
terragrunt apply -target=module.traefik
terragrunt apply -target=module.cloudflared
```

After those allocations are stable, deploy NATS and its protected host volume:

```sh
cd terraform/live/interserver-run4w4y/nats
terragrunt apply

cd ../nomad
terragrunt apply \
  -target=nomad_dynamic_host_volume.nats_data \
  -target=module.nats
```

The `chromium` allocation uses the upstream `chromedp/headless-shell` image
pinned by version and digest. It exposes Chrome DevTools Protocol port 9222
only through Consul Connect; the sole allowed client is `cv-pdf-worker`.
There is no custom browser image or CV application code in that allocation.
Deploy it after applying the Consul intentions:

```sh
cd terraform/live/interserver-run4w4y/nomad
terragrunt apply -target=module.chromium
```

Once NATS is healthy, apply `terraform/live/prod/jetstream` from the adjacent
CV repository. That post-NATS stack creates the application stream and durable
PDF consumer before any CV allocation is enabled.

Finish with a full `terragrunt plan`; targeted applies are only used here to
avoid restarting all mesh-connected workloads at once.

The Ente server image is pinned by digest. Its former mutable `latest` tag is
no longer pullable anonymously from GHCR, so changing that digest requires
confirming registry access or ensuring the selected image is present on every
eligible Nomad node before rollout.
