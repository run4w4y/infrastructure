locals {
  pages_projects = {
    for project_key, project in var.pages_projects : project_key => {
      project_name      = coalesce(project.project_name, project_key)
      production_branch = project.production_branch
      domains           = project.domains
      build_config      = project.build_config
    }
  }

  pages_domains = {
    for domain in flatten([
      for project_key, project in local.pages_projects : [
        for hostname in project.domains : {
          key         = "${project_key}:${hostname}"
          project_key = project_key
          hostname    = hostname
          fqdn        = "${hostname}.${var.domain_name}"
        }
      ]
    ]) : domain.key => domain
  }
}

resource "cloudflare_pages_project" "this" {
  for_each = local.pages_projects

  account_id        = var.cloudflare_account_id
  name              = each.value.project_name
  production_branch = each.value.production_branch
  build_config      = each.value.build_config
}

resource "cloudflare_pages_domain" "this" {
  for_each = local.pages_domains

  account_id   = var.cloudflare_account_id
  project_name = cloudflare_pages_project.this[each.value.project_key].name
  name         = each.value.fqdn
}

resource "cloudflare_dns_record" "pages_domains" {
  for_each = local.pages_domains

  zone_id = cloudflare_zone.this.id
  name    = each.value.fqdn
  type    = "CNAME"
  ttl     = 1
  content = cloudflare_pages_project.this[each.value.project_key].subdomain
  proxied = true
}
