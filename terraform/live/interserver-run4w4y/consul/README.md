# Consul

## Before running terraform
Consul has to already be deployed with Ansible, refer to `/deployment/ansible` on how to get Consul running

## Required environment variables
- `CONSUL_HTTP_ADDR` - Consul address
- `CONSUL_HTTP_TOKEN` - Consul token (master ACL token)

## Applying configuration
Check the terraform plan
```bash
terragrunt plan
```

If the plan looks alright, apply the changes
```bash
terragrunt apply
```

## Reading and using created tokens

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
