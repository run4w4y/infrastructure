# Vault

## Before running Terraform

Vault has to already be deployed, initialized, and unsealed with Ansible.

## Required environment variables

- `VAULT_ADDR` - Vault address.
- `VAULT_TOKEN` - Vault token Terraform uses to configure Vault.
- `CONSUL_HTTP_ADDR` - Consul address used by the Vault Consul secrets backend.
- `CONSUL_HTTP_TOKEN` - Consul token used by the Vault Consul secrets backend.

The parent environment `.envrc` loads `/terraform` from Infisical automatically when entering `terraform/live/interserver-run4w4y` and the Infisical CLI is authenticated.

## Applying Configuration

Check the Terraform plan:

```bash
terragrunt plan
```

If the plan looks alright, apply the changes:

```bash
terragrunt apply
```
