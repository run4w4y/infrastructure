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

output "pages_projects" {
  description = "Map of Cloudflare Pages project keys to project names and pages.dev subdomains"
  value = {
    for key, project in cloudflare_pages_project.this :
    key => {
      name      = project.name
      subdomain = project.subdomain
    }
  }
}

output "pages_domains" {
  description = "Map of Cloudflare Pages custom domains to Pages domain status and DNS record IDs"
  value = {
    for key, domain in cloudflare_pages_domain.this :
    key => {
      name          = domain.name
      project_name  = domain.project_name
      status        = domain.status
      dns_record_id = cloudflare_dns_record.pages_domains[key].id
    }
  }
}
