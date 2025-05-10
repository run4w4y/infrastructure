# Ansible deployment

## Running for a specific environment
By default, all the playbooks will be run for the `interserver-run4w4y` environment, as specified in the `ansible.cfg`

If you want to run a playbook for another environment, specify the environment's inventory with an argument `-i ./environments/env/hosts.cfg`, where `env` is the name of your target deployment environment. To create a new one, just take a look at how the default environment is defined.

**TODO: better inventories**

You also should specify the ssh password for the server you're running the playbook for with an environment variable `ANSIBLE_PASSWORD`

## Install roles from Ansible Galaxy
Before proceeding, make sure that all of the roles are present:
```bash
ansible-galaxy install -r requirements.yml
```

## Consul
**TODO: Automate agent token creation**

On a fresh deployment, Consul should be the first one to be provisioned

To deploy Consul, just run

```bash
ansible-playbook playbooks/consul.yml
```

Grab both the master and replication ACL tokens from your newly bootstrapped Consul, and save them in the group_vars:
```bash
ansible-vault create ./environments/dev/group_vars/consul_instances
```

```yaml
consul_acl_master_token: ...
consul_acl_replication_token: ...
```

Now, create a node-identity ACL token and set it as the agent token
```bash
consul acl token create -node-identity 'host1:dc1'
consul acl set-agent-token agent <secret-id>
```

To configure Consul after deployment, refer to the `/terraform/live/.../consul` directory for your specific deployment environment

## Vault

### Create a group_vars file
Before running the playbook, create an encrypted `group_vars` file with a Consul token to be used by Vault (you can get one by running Terraform for the `consul` module)

```bash
# replace ... with your target deployment environment
ansible-vault create ./environments/.../group_vars/vault_instances
```

### Fill in the Consul token

The contents should be like this

```yaml
vault_consul_token: <consul acl token>
```

Ideally, here you would want to use a token created specifically for Vault and not the master ACL token you got from deploying Consul earlier

Running Terraform for Consul should give you a token with appropriate permissions for usage with Vault, so you should be using that token here

### Run the playbook

After that, you can run the playbook without any issues, running it will prompt you for a password you previously used when creating the vars file

```bash
ansible-playbook --ask-vault-pass playbooks/vault.yml
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

### Create a group_vars file
Just like before, we need to provide tokens for Vault and Consul for this deployment with a `group_vars` file

There are two tokens necessary for this, one for Vault and one for Consul. Same as with tokens for running the Vault playbook, Terraform for both Vault and Consul has outputs that provide these tokens with appropriate permissions, so you should be using those.

To create the file, run
```bash
ansible-vault create environments/dev/group_vars/nomad_instances
```

Contents of this file should look like this
```yaml
nomad_consul_token: <consul token from tf output>
nomad_vault_token: <vault token from tf output>
```

### Run the playbook
```bash
ansible-playbook --ask-vault-pass playbooks/nomad.yml
```

### After deployment

#### ACL bootstrap
To get the bootstrap token and initialize the ACL system run
```bash
nomad acl bootstrap
```

#### Terraform
When you're done deploying, refer to `/deployment/terraform/live/dev/nomad` directory for Terraform set up
