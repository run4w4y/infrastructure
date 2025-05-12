resource "consul_acl_auth_method" "nomad" {
  name = "nomad-workloads"
  type = "jwt"

  config_json = jsonencode({
    JWKSURL          = "http://nomad-servers.service.consul:4646/.well-known/jwks.json"
    JWTSupportedAlgs = ["RS256"]
    BoundAudiences   = ["consul.io"]
    ClaimMappings = {
      nomad_job_id    = "nomad_job_id"
      nomad_namespace = "nomad_namespace"
      nomad_service   = "nomad_service"
      nomad_task      = "nomad_task"
    }
  })
}

resource "consul_acl_binding_rule" "nomad_service" {
  auth_method = consul_acl_auth_method.nomad.name
  bind_type   = "service"
  bind_name   = "$${value.nomad_service}"
  selector    = "\"nomad_service\" in value"
}

# non-service nomad tasks role

resource "consul_acl_policy" "nomad_tasks" {
  name  = "nomad-tasks-policy"
  rules = <<EOF
    key_prefix "" {
      policy = "read"
    }

    node_prefix "" {
      policy = "read"
    }

    service_prefix "" {
      policy = "read"
    }
  EOF
}

resource "consul_acl_role" "nomad_tasks" {
  name        = "nomad-tasks"
  description = "read access for nomad tasks"
  policies    = [consul_acl_policy.nomad_tasks.id]
}

resource "consul_acl_binding_rule" "nomad_tasks" {
  auth_method = consul_acl_auth_method.nomad.name
  bind_type   = "role"
  bind_name   = consul_acl_role.nomad_tasks.name
  selector    = "\"nomad_service\" not in value"
}

# traefik specific permission handling

resource "consul_acl_policy" "traefik_policy" {
  name  = "traefik"
  rules = <<EOF
key_prefix "traefik" {
  policy = "write"
}

service "traefik" {
  policy = "write"
}

agent_prefix "" {
  policy = "read"
}

node_prefix "" {
  policy = "read"
}

service_prefix "" {
  policy = "read"
}
EOF
}

resource "consul_acl_role" "traefik_role" {
  name        = "traefik"
  description = "ACL role for Traefik workload identity"
  policies    = [consul_acl_policy.traefik_policy.name]
}

resource "consul_acl_binding_rule" "traefik_rule" {
  auth_method = consul_acl_auth_method.nomad.name
  bind_type   = "role"
  bind_name   = consul_acl_role.traefik_role.name
  selector    = <<EOF
value.nomad_job_id == "traefik"
EOF
}
