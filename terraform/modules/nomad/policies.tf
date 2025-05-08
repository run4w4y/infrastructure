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
