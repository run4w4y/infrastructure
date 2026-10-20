variable "access_team_name" {
  description = "Cloudflare Access team name enforced by the administrative tunnel origins."
  type        = string

  validation {
    condition     = length(trimspace(var.access_team_name)) > 0
    error_message = "The Cloudflare Access team name must not be empty."
  }
}

variable "owner_emails" {
  description = "Individual operator identities allowed through the administrative Access applications."
  type        = set(string)

  validation {
    condition = length(var.owner_emails) > 0 && alltrue([
      for email in var.owner_emails : can(regex("^[^@[:space:]]+@[^@[:space:]]+\\.[^@[:space:]]+$", email))
    ])
    error_message = "At least one individual operator email address is required."
  }
}

locals {
  admin_services = toset(["nomad", "vault", "consul"])
  mfa = {
    allowed_authenticators = ["totp", "biometrics", "security_key"]
    mfa_disabled           = true
    session_duration       = "8h"
  }
}

resource "cloudflare_zero_trust_access_policy" "cluster_operator" {
  account_id       = var.cloudflare_account_id
  name             = "Cluster operator"
  decision         = "allow"
  session_duration = "8h"

  include = [for email in sort(tolist(var.owner_emails)) : {
    email = { email = email }
  }]

  mfa_config = local.mfa
}

resource "cloudflare_zero_trust_access_application" "admin" {
  for_each = local.admin_services

  account_id       = var.cloudflare_account_id
  name             = "${title(each.key)} administration"
  domain           = "${each.key}.${var.domain_name}"
  type             = "self_hosted"
  session_duration = "8h"

  app_launcher_visible       = true
  http_only_cookie_attribute = true
  same_site_cookie_attribute = "lax"
  enable_binding_cookie      = true
  options_preflight_bypass   = false
  mfa_config                 = local.mfa

  policies = concat(
    [{
      id         = cloudflare_zero_trust_access_policy.cluster_operator.id
      precedence = 1
    }],
    [
      for index, client in local.application_service_clients[each.key] : {
        id         = cloudflare_zero_trust_access_policy.service_client[client].id
        precedence = index + 2
      }
    ],
  )

  lifecycle {
    prevent_destroy = true
  }
}

output "admin_applications" {
  description = "Per-hostname Access audiences consumed by the Cloudflare Tunnel configuration."
  value = {
    for name, app in cloudflare_zero_trust_access_application.admin : name => {
      id       = app.id
      hostname = app.domain
      audience = app.aud
    }
  }
}
