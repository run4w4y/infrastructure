output "nameservers" {
  description = "Authoritative name-servers you must set at Porkbun"
  value       = cloudflare_zone.this.name_servers
}

output "tunnel_id" {
  description = "UUID of the Cloudflare Zero-Trust tunnel"
  value       = cloudflare_zero_trust_tunnel_cloudflared.this_tunnel.id
}

output "tunnel_cname_target" {
  description = "Connector hostname (<uuid>.cfargotunnel.com)"
  value       = "${cloudflare_zero_trust_tunnel_cloudflared.this_tunnel.id}.cfargotunnel.com"
}

output "app_hostnames" {
  description = "Map of application hostnames → DNS record IDs"
  value = {
    for host, rec in cloudflare_dns_record.apps :
    host => rec.id
  }
}
