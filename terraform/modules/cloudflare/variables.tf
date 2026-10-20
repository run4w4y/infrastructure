variable "domain_name" {
  description = "Your domain name (e.g., example.com)"
  type        = string
}

variable "cloudflare_account_id" {
  description = "Your cloudflare account id"
  type        = string
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token with permissions for zone management, DNS records, tunnels, Pages, and Access management"
  type        = string
  sensitive   = true
}

variable "porkbun_api_key" {
  description = "Porkbun API key"
  type        = string
  sensitive   = true
}

variable "porkbun_secret_key" {
  description = "Porkbun API secret key"
  type        = string
  sensitive   = true
}

variable "vault_address" {
  description = "Vault deployment address"
  type        = string
  default     = "http://127.0.0.1:8200"
}

variable "traefik_address" {
  description = "Traefik deployment address (unmatched ingress will be routed here)"
  type        = string
  default     = "http://127.0.0.1:8080"
}

variable "tunnel_name" {
  type    = string
  default = "nomad-tunnel"
}

variable "ingress_rules" {
  type = list(object({
    hostname = string
    service  = string
    origin_request = optional(object({
      ca_pool                = string
      origin_server_name     = string
      connect_timeout        = optional(number, 10)
      keep_alive_connections = optional(number, 100)
      keep_alive_timeout     = optional(number, 90)
      no_happy_eyeballs      = optional(bool, false)
      no_tls_verify          = optional(bool, false)
      proxy_type             = optional(string, "")
      tcp_keep_alive         = optional(number, 30)
      tls_timeout            = optional(number, 10)
    }))
  }))

  validation {
    condition = alltrue([
      for rule in var.ingress_rules :
      !contains(["nomad", "vault", "consul"], rule.hostname) || try(
        startswith(rule.service, "https://") &&
        length(rule.origin_request.ca_pool) > 0 &&
        length(rule.origin_request.origin_server_name) > 0,
        false
      )
    ])
    error_message = "Administrative tunnel routes require verified HTTPS origins."
  }
}

variable "pages_projects" {
  description = "Cloudflare Pages projects to create. Domains are hostnames relative to domain_name, for example \"cv\" creates cv.example.com."
  type = map(object({
    project_name      = optional(string)
    production_branch = optional(string, "main")
    domains           = optional(set(string), [])
    build_config = optional(object({
      build_caching       = optional(bool)
      build_command       = optional(string)
      destination_dir     = optional(string)
      root_dir            = optional(string)
      web_analytics_tag   = optional(string)
      web_analytics_token = optional(string)
    }))
  }))
  default = {}
}
