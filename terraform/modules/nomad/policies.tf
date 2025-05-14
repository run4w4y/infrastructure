resource "nomad_acl_policy" "metrics_collector" {
  name      = "metrics-collector"
  rules_hcl = <<EOT
    node {
        policy = "read"
    }

    agent {
        policy = "read"
    }

    operator {
        policy = "deny"
    }

    plugin {
        policy = "deny"
    }
    EOT
}

resource "nomad_acl_policy" "allocation_observer" {
  name      = "allocation-observer"
  rules_hcl = <<EOT
    namespace "*" {
        policy = "read"
        capabilities = ["read-job"]
    }
    EOT
}

resource "nomad_acl_policy" "ci_deploy" {
  name      = "ci-deploy"
  rules_hcl = <<EOT
namespace "*" {
  policy = "write"
}

allocation {
  policy = "read"
}

agent {
  policy = "read"
}

operator {
  policy = "read"
}
EOT
}

resource "nomad_acl_token" "ci_deploy" {
  name     = "ci-deploy-token"
  type     = "client"
  policies = [nomad_acl_policy.ci_deploy.id]
}

output "ci-deploy-token" {
  description = "Token to be used with deploy jobs in the Github Actions workflows"
  value       = nomad_acl_token.ci_deploy.secret_id
  sensitive   = true
}
