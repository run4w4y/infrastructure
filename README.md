# infrastructure
My server infrastructure

# Shell and secrets

The root shell is managed by `direnv` and the Nix flake. Terraform live environments can additionally load runtime variables from Infisical through `infisical export`.

Set the appropriate `INFISICAL_PROJECT_ID` in the root `.envrc`. For the deployment targets, there are additional variables that have to be set in their respective `.envrc` files. You may refer to existing environments under `/terraform/live` for setup examples.

For `terraform/live/interserver-run4w4y`, entering the directory loads `/terraform` from the configured Infisical environment when the CLI is authenticated. Ansible intentionally stays explicit; run playbooks through `infisical run --env=prod --path=/ansible -- ...`.

# Terraform and state management

I am using HCP for TF state management in `terraform/live/interserver-run4w4y`. Run `terraform login` to be able to access the state. Refer to `.envrc` and `terragrunt.hcl` files for adjusting the setup.

# Step by step deployment
1. Run the Consul deployment playbook.
2. Run the Consul Terraform
3. Run the Vault Ansible playbook
4. Run the Vault Terraform
5. Run the Nomad Ansible playbook
6. Run the Cloudflare Terraform
6. Run the Nomad Terraform
