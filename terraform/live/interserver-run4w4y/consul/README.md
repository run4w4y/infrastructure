# Consul

## Before running terraform
Consul has to already be deployed with Ansible, refer to `/deployment/ansible` on how to get Consul running

## Required environment variables
- `CONSUL_HTTP_ADDR` - Consul address
- `CONSUL_HTTP_TOKEN` - Consul token (master ACL token)
- `INFISICAL_PROJECT_ID` - optional; when set, Terraform publishes service-specific Consul ACL tokens to Infisical

The parent environment `.envrc` loads `/terraform` from Infisical automatically when entering `terraform/live/interserver-run4w4y` and the Infisical CLI is authenticated.

When publishing to Infisical, authenticate the provider with the Infisical environment variables for your chosen auth method, such as Universal Auth or an access token.

## Applying configuration
Check the terraform plan
```bash
terragrunt plan
```

If the plan looks alright, apply the changes
```bash
terragrunt apply
```

## Publishing created tokens

When `INFISICAL_PROJECT_ID` is set, Terraform writes service-specific Consul ACL tokens into Infisical under `/ansible` by default:

- `VAULT_CONSUL_TOKEN`
- `NOMAD_CONSUL_TOKEN`

Make sure that folder exists in Infisical before applying.

You can override the target folder with `INFISICAL_ANSIBLE_FOLDER_PATH`, the Infisical environment with `INFISICAL_ENV`, and the host with `INFISICAL_HOST`.

## Reading and using created tokens manually

### DNS token
Reading the token from TF output

```bash
terragrunt output consul_acl_token_dns
```

You can set this token as the default agent-token

```bash
consul acl set-agent-token default <secret_id of the token>
```

### Vault token
Reading the token from TF output

```bash
terragrunt output consul_acl_token_vault
```

You can use this token for the Vault deployment with Ansible (use this token in the `group_vars/vault_instances` variable file)

### Nomad token

Reading the token from TF output

```bash
terragrunt output consul_acl_token_nomad
```

You can use this token for the Nomad deployment with Ansible (use this token in the `group_vars/nomad_instances` variable file)
