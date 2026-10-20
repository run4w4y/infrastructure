# Infisical shape

This workspace manages the deployment project's secret folders and seeds, three
public administrative endpoint values, the public cluster CA, and dedicated CI
projects and GitHub OIDC identities.

Enter the workspace through the project shell so direnv loads the selected
deployment environment's `/terraform` values. Required inputs are
`INFISICAL_PROJECT_ID`, `INFISICAL_ENV`, `DOMAIN_NAME`, and `CLUSTER_CA_BASE64`.
The live configuration decodes the single-line CA into `cluster_ca_pem`.
`INFISICAL_ORG_ID` selects the organization that owns the CI identities.

Authenticate with the existing Infisical CLI session. The root `.envrc` exports
its user token as `INFISICAL_TOKEN` for the provider; the account must have the
organization and project permissions needed to manage these resources.
`TF_CLOUD_ORGANIZATION`, `TF_CLOUD_PROJECT`, and `INFISICAL_PROJECT_ID` stay in
local direnv configuration.

Review the plan from this directory:

```sh
terragrunt plan
```

The endpoint migration moves only `CONSUL_HTTP_ADDR`, `NOMAD_ADDR`, and
`VAULT_ADDR` from their existing seed instances to managed endpoint instances.
Their values become `https://consul.<DOMAIN_NAME>`,
`https://nomad.<DOMAIN_NAME>`, and `https://vault.<DOMAIN_NAME>`.
Apply this migration after those public APIs accept the operator's Access
service credential and their native ACL tokens. Review that the plan preserves
the existing secret IDs and changes no credential values.

The Cloudflare module manages the operator's `CF_ACCESS_CLIENT_ID` and
`CF_ACCESS_CLIENT_SECRET` in `/terraform`. These authorize all three
administrative Access applications; native service tokens still authorize their
APIs. Other user-filled placeholders and server IP references retain their
existing seed-only behavior.

Each CI repository has a separate Infisical project containing only its Access
credential and scoped `NOMAD_TOKEN` in the `prod` environment's root folder.
GitHub OIDC identities have the built-in Viewer role in their own projects.
They have no membership in the deployment project.

After reviewing the complete plan, apply it and inspect the nonsecret outputs:

```sh
terragrunt apply
terragrunt output placeholder_secrets
terragrunt output derived_secrets
terragrunt output administrative_endpoints
```

`placeholder_secrets` and `derived_secrets` describe only seed secrets.
`administrative_endpoints` describes continuously managed public addresses.
Import existing remote folders or secrets into state rather than deleting and
recreating them.
