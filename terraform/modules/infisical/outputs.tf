output "paths" {
  description = "Infisical paths managed by this module."
  value = {
    root      = "/"
    terraform = local.terraform_path
    ansible   = local.ansible_path
  }
}

output "placeholder_secrets" {
  description = "Secrets initialized with dummy values for a user to fill later."
  value = {
    for path, secrets in local.secret_shape :
    path => sort([
      for name, secret in secrets :
      name
      if secret.kind == "user-placeholder"
    ])
  }
}

output "derived_secrets" {
  description = "Secrets initialized as Infisical reference values."
  value = {
    for path, secrets in local.secret_shape :
    path => {
      for name, secret in secrets :
      name => secret.value
      if secret.kind == "derived-reference"
    }
    if length([
      for name, secret in secrets :
      name
      if secret.kind == "derived-reference"
    ]) > 0
  }
}
