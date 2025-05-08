resource "consul_acl_auth_method" "nomad" {
  name = "nomad-workloads"
  type = "jwt"

  config_json = jsonencode({
    JWKSURL          = local.jwks_url
    JWTSupportedAlgs = ["RS256"]
    BoundAudiences   = local.audiences
    ClaimMappings    = local.claim_mappings
  })
}

resource "consul_acl_binding_rule" "nomad_service" {
  auth_method = consul_acl_auth_method.nomad[0].name
  bind_type   = "service"
  bind_name   = "$${value.nomad_service}"
  selector    = "\"nomad_service\" in value"
}
