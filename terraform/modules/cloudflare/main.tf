# creates a cloudflare zone
resource "cloudflare_zone" "this" {
  name = var.domain_name
  type = "full"

  account = {
    id = var.cloudflare_account_id
  }
}

# request nameservers change to the cloudflare ones
resource "porkbun_nameservers" "to_cloudflare" {
  domain      = var.domain_name
  nameservers = cloudflare_zone.this.name_servers
}

# create a cloudflare tunnel
resource "cloudflare_zero_trust_tunnel_cloudflared" "this_tunnel" {
  account_id    = var.cloudflare_account_id
  name          = var.tunnel_name
  tunnel_secret = jsondecode(data.vault_kv_secret_v2.cloudflared_tunnel_secret.data_json).secret
  config_src    = "cloudflare"
}

# configure ingress rules for the tunnel
resource "cloudflare_zero_trust_tunnel_cloudflared_config" "this_tunnel_cfg" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.this_tunnel.id
  source     = "cloudflare"

  config = {
    ingress = concat([
      for r in var.ingress_rules : {
        hostname = "${r.hostname}.${var.domain_name}"
        service  = r.service
      }
    ], [{ service = var.traefik_address }])
  }
}

# proxy dns records for the specified subdomains
resource "cloudflare_dns_record" "apps" {
  for_each = {
    for r in var.ingress_rules : r.hostname => {
      host_fqdn = "${r.hostname}.${var.domain_name}"
    }
  }

  zone_id = cloudflare_zone.this.id
  name    = each.key
  type    = "CNAME"
  ttl     = 1
  content = "${cloudflare_zero_trust_tunnel_cloudflared.this_tunnel.id}.cfargotunnel.com"
  proxied = true
}
