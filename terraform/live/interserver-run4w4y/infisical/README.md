# Infisical shape

This stack manages the Infisical shape for the `interserver-run4w4y` deployment.

It creates the root `SERVER_IP_ADDRESS` placeholder, the `/terraform` and `/ansible` folders, dummy values for user-filled secrets, and reference values such as `CONSUL_HTTP_ADDR`.

`TF_CLOUD_ORGANIZATION`, `TF_CLOUD_PROJECT`, and `INFISICAL_PROJECT_ID` stay in direnv-local config rather than Infisical.

Required local environment:

- `INFISICAL_PROJECT_ID`
- Infisical provider authentication, such as Universal Auth or an Infisical access token

```bash
terragrunt plan
terragrunt apply
terragrunt output placeholder_secrets
terragrunt output derived_secrets
```

If Infisical reports that a folder or secret already exists on the first apply, import it into the matching Terraform resource instead of deleting and recreating it.
