locals {
  ansible_path   = "/${var.ansible_folder_name}"
  terraform_path = "/${var.terraform_folder_name}"

  placeholder_value = "TODO_FILL_ME"

  common_metadata = {
    managed_by  = "terraform"
    module      = "terraform/modules/infisical"
    environment = var.environment_slug
  }

  folders = {
    (local.terraform_path) = {
      parent_path = "/"
      name        = var.terraform_folder_name
      description = "Terraform runtime variables."
    }
    (local.ansible_path) = {
      parent_path = "/"
      name        = var.ansible_folder_name
      description = "Ansible runtime variables."
    }
  }

  secret_shape = {
    "/" = {
      SERVER_IP_ADDRESS = {
        value       = local.placeholder_value
        description = "Primary server IP address used by Terraform and Ansible."
        kind        = "user-placeholder"
      }
    }

    (local.terraform_path) = {
      CF_ACCOUNT_ID = {
        value       = local.placeholder_value
        description = "Cloudflare account ID."
        kind        = "user-placeholder"
      }
      CF_API_TOKEN = {
        value       = local.placeholder_value
        description = "Cloudflare API token."
        kind        = "user-placeholder"
      }
      CONSUL_HTTP_ADDR = {
        value       = format("$${%s.SERVER_IP_ADDRESS}:8500", var.environment_slug)
        description = "Consul HTTP address derived from SERVER_IP_ADDRESS."
        kind        = "derived-reference"
      }
      CONSUL_HTTP_TOKEN = {
        value       = local.placeholder_value
        description = "Consul bootstrap/admin ACL token."
        kind        = "user-placeholder"
      }
      DOMAIN_NAME = {
        value       = local.placeholder_value
        description = "Primary domain for the deployment."
        kind        = "user-placeholder"
      }
      ENTE_ADMIN_USER_ID = {
        value       = local.placeholder_value
        description = "Ente admin user ID."
        kind        = "user-placeholder"
      }
      NOMAD_ADDR = {
        value       = format("http://$${%s.SERVER_IP_ADDRESS}:4646/", var.environment_slug)
        description = "Nomad address derived from SERVER_IP_ADDRESS."
        kind        = "derived-reference"
      }
      NOMAD_TOKEN = {
        value       = local.placeholder_value
        description = "Nomad bootstrap/admin ACL token."
        kind        = "user-placeholder"
      }
      PB_API_KEY = {
        value       = local.placeholder_value
        description = "Porkbun API key."
        kind        = "user-placeholder"
      }
      PB_SECRET_KEY = {
        value       = local.placeholder_value
        description = "Porkbun secret API key."
        kind        = "user-placeholder"
      }
      VAULT_ADDR = {
        value       = format("http://$${%s.SERVER_IP_ADDRESS}:8200/", var.environment_slug)
        description = "Vault address derived from SERVER_IP_ADDRESS."
        kind        = "derived-reference"
      }
      VAULT_TOKEN = {
        value       = local.placeholder_value
        description = "Vault root/admin token."
        kind        = "user-placeholder"
      }
    }

    (local.ansible_path) = {
      CONSUL_ACL_MASTER_TOKEN = {
        value       = local.placeholder_value
        description = "Consul ACL master token created during bootstrap."
        kind        = "user-placeholder"
      }
      CONSUL_ACL_REPLICATION_TOKEN = {
        value       = local.placeholder_value
        description = "Consul ACL replication token created during bootstrap."
        kind        = "user-placeholder"
      }
      SERVER_IP_ADDRESS = {
        value       = format("$${%s.SERVER_IP_ADDRESS}", var.environment_slug)
        description = "Server IP address derived from the root SERVER_IP_ADDRESS secret."
        kind        = "derived-reference"
      }
      SERVER_SSH_PASSWORD = {
        value       = local.placeholder_value
        description = "SSH password for the deployment server."
        kind        = "user-placeholder"
      }
    }
  }

  secrets = merge([
    for path, secrets in local.secret_shape : {
      for name, secret in secrets :
      "${path}:${name}" => merge(secret, {
        name        = name
        folder_path = path
      })
    }
  ]...)
}
