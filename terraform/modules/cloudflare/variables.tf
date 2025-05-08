variable "domain_name" {
  description = "Your domain name (e.g., example.com)"
  type        = string
}

variable "cloudflare_account_id" {
  description = "Your cloudflare account id"
  type        = string
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token with Tunnel + Zone:Read permissions"
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
  }))

  default = [
    { hostname = "nomad", service = "http://127.0.0.1:4646" },
    { hostname = "vault", service = "http://127.0.0.1:8200" },
    { hostname = "consul", service = "http://127.0.0.1:8500" }
  ]
}
