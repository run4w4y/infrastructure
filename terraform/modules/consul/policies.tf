// dns policy
resource "consul_acl_policy" "dns_policy" {
  name = "dns-policy"

  rules = <<-RULE
    node_prefix "" {
      policy = "read"
    }

    service_prefix "" {
      policy = "read"
    }
  RULE
}

// vault policy
resource "consul_acl_policy" "vault_policy" {
  name = "vault-policy"

  rules = <<-RULE
    key_prefix "vault/" {
      policy = "write"
    }

    service "vault" {
      policy = "write"
    }

    agent_prefix "" {
      policy = "read"
    }

    session_prefix "" {
      policy = "write"
    }
  RULE
}

// nomad policy
resource "consul_acl_policy" "nomad_policy" {
  name = "nomad-policy"

  rules = <<-RULE
    key_prefix "" {
      policy = "read"
    }

    agent_prefix "" {
      policy = "read"
    }

    node_prefix "" {
      policy = "read"
    }

    service_prefix "" {
      policy = "write"
    }

    acl  = "write"
    mesh = "write"
  RULE
}
