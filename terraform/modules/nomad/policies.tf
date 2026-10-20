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
# Application jobs currently share Nomad's default namespace. Keep the token
# there until a reviewed namespace migration moves every live dependency at
# once, but grant only the job registration/read operations used by CI.
namespace "default" {
  capabilities = [
    "list-jobs",
    "parse-job",
    "read-job",
    "submit-job",
  ]
}
EOT
}

resource "nomad_acl_token" "ci_repository" {
  for_each = toset(["infrastructure", "cv"])

  name     = "ci-${each.key}-deploy-token"
  type     = "client"
  policies = [nomad_acl_policy.ci_deploy.id]
}
