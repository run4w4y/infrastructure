# Infisical

This module manages the deployment project's `/terraform` and `/ansible`
folders, its secret seeds, the public cluster CA, and separate CI projects and
GitHub OIDC identities for the infrastructure and CV repositories.

The deployment environment comes from `environment_slug`. Folder names can be
changed with `terraform_folder_name` and `ansible_folder_name`.

## Seed values and managed values

`infisical_secret.this` initializes user-filled placeholders and references to
the root `SERVER_IP_ADDRESS`. It writes seeds through `value_wo` once and ignores
later value changes. Existing native ACL tokens and user credentials remain
user-managed.

`infisical_secret.administrative_endpoint` continuously manages three values in
the Terraform folder from `domain_name`:

| Name | Value |
| --- | --- |
| `CONSUL_HTTP_ADDR` | `https://consul.<domain_name>` |
| `NOMAD_ADDR` | `https://nomad.<domain_name>` |
| `VAULT_ADDR` | `https://vault.<domain_name>` |

The native `moved` blocks preserve the existing secrets' identities when moving
them out of the seed resource. They name the existing `/terraform` addresses;
deployments using a different Terraform folder need corresponding state moves.

Apply this migration after all three public endpoints accept the operator's
Cloudflare Access service credential and their native ACL tokens. The Cloudflare
module publishes `CF_ACCESS_CLIENT_ID` and `CF_ACCESS_CLIENT_SECRET` to the
deployment's Terraform folder. Providers send those headers alongside their
native authorization. The endpoint resources manage their values on later
applies and retain `prevent_destroy`.

`CLUSTER_CA_BASE64` is a managed, single-line encoding of the existing public
cluster CA supplied as `cluster_ca_pem`. Consumers decode it for internal TLS.
Private certificate keys remain on the cluster host.

`placeholder_secrets` and `derived_secrets` list only seed values.
`administrative_endpoints` lists the three managed public addresses.

## CI isolation

Each repository has its own Infisical project and exact GitHub OIDC identity.
The identity receives the built-in Viewer role only in that project. CI uses
the `prod` environment and root folder `/`; it cannot read the deployment
project's operator or application secrets.

The Cloudflare and Nomad modules publish only the repository's Access client ID,
Access client secret, and scoped `NOMAD_TOKEN` to its CI project. CI projects and
identities are separate from the deployment's selected environment.

If an existing folder or secret is absent from Terraform state, import it before
applying. Do not recreate an existing remote object to adopt it.
