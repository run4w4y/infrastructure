# Ansible deployment

## Running for a specific environment
By default, all the playbooks will be run for the `interserver-run4w4y` environment, as specified in the `ansible.cfg`

If you want to run a playbook for another environment, specify the environment's inventory with an argument `-i ./environments/env/hosts.cfg`, where `env` is the name of your target deployment environment. To create a new one, just take a look at how the default environment is defined.

**TODO: better inventories**

You also should specify the server address and SSH password through `SERVER_IP_ADDRESS` and `SERVER_SSH_PASSWORD`.

## Install roles from Ansible Galaxy
Before proceeding, make sure that all of the roles are present:
```bash
ansible-galaxy install -r requirements.yml
```

## Secrets

Secrets are expected to be injected into the Ansible process by the Infisical CLI. The environment-specific `group_vars` files map those environment variables to the role variables expected by the Consul, Vault, and Nomad roles.

Unlike Terraform live directories, the Ansible directory does not automatically load one Infisical environment on `cd`; choose it explicitly per playbook run.

For the default environment:

```bash
infisical run \
  --env=prod \
  --path=/ansible \
  -- ansible-playbook playbooks/nomad.yml
```

When running Terraform for Consul, Terraform can publish the service-specific Consul ACL tokens into the same Infisical folder when `INFISICAL_PROJECT_ID` is set in the shell.

## Consul
**TODO: Automate agent token creation**

On a fresh deployment, Consul should be the first one to be provisioned

To deploy Consul, just run

```bash
ansible-playbook playbooks/consul.yml
```

Grab both the master and replication ACL tokens from your newly bootstrapped Consul, and save them in Infisical:
```bash
CONSUL_ACL_MASTER_TOKEN=...
CONSUL_ACL_REPLICATION_TOKEN=...
```

The `consul_instances` group vars file reads these values from the environment.

Now, create a node-identity ACL token and set it as the agent token
```bash
consul acl token create -node-identity 'host1:dc1'
consul acl set-agent-token agent <secret-id>
```

To configure Consul after deployment, refer to the `/terraform/live/.../consul` directory for your specific deployment environment

## Vault

Before running the playbook, make sure `VAULT_CONSUL_TOKEN` is available from Infisical. Terraform for Consul can publish this token automatically; it is the Consul ACL token created specifically for Vault.

### Run the playbook

```bash
infisical run \
  --env=prod \
  --path=/ansible \
  -- ansible-playbook playbooks/vault.yml
```

### After deployment

#### Getting the init tokens

To initialize Vault and get the root and unseal tokens run
```bash
vault operator init -key-shares=1 -key-threshold=1
```

#### Unsealing the Vault
```bash
vault operator unseal
```

#### Terraform
With Vault up and running, you should apply Terraform to set it up. Refer to `/deployment/terraform/live/dev/vault` directory for further details.

## Nomad

Before running the playbook, make sure `NOMAD_CONSUL_TOKEN` is available from Infisical.

Terraform for Consul can publish `NOMAD_CONSUL_TOKEN` automatically. Vault access for workloads uses Nomad workload identities, so no Nomad server Vault token is required.

### Run the playbook
```bash
infisical run \
  --env=prod \
  --path=/ansible \
  -- ansible-playbook playbooks/nomad.yml
```

### After deployment

#### ACL bootstrap
To get the bootstrap token and initialize the ACL system run
```bash
nomad acl bootstrap
```

#### Terraform
When you're done deploying, refer to `/deployment/terraform/live/dev/nomad` directory for Terraform set up
