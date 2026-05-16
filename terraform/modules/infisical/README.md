# Infisical

This module defines the Infisical shape used by this repository.

It creates the fixed folder structure for one deployment project:

- `/`
- `/terraform`
- `/ansible`

The `terraform` and `ansible` folder names can be changed with module variables if a project needs different names.

It also creates placeholder secrets that should be filled in by a user later. Secrets use `value_wo` so Terraform can write the initial value without keeping the value in state.

Derived values, such as `CONSUL_HTTP_ADDR`, are initialized as Infisical secret references to `SERVER_IP_ADDRESS`.

If a secret already exists in Infisical but is not in Terraform state, import it rather than recreating it. Terraform cannot silently adopt existing remote objects on apply.
