job [[ .my.job_name | quote ]] {
  datacenters = [[ .my.datacenters | toStringList ]]
  type = "service"

  group "ente-web" {
    count = [[ .my.count ]]

    network {
      mode = "bridge"

      [[- $ports := .my.ports -]]
      [[ range keys .my.ports ]]
      port [[ quote . ]] {
        to = [[ index $ports . ]]
      }
      [[ end ]]
    }

    [[- $subdomains := .my.subdomains -]]
    [[ range keys .my.subdomains ]]
    service {
      name = "ente-web-[[ . ]]"
      task = "ente-web"
      port = [[ index $ports . | quote ]]

      tags = [
        "traefik.enable=true",
        "traefik.consulcatalog.connect=true",
        "traefik.subdomain=[[ index $subdomains . ]]",
        "traefik.http.routers.ente-web-[[ . ]].entrypoints=web"
      ]

      connect {
        sidecar_service {
          proxy {}
        }
      }
    }
    [[ end ]]

    task "ente-web" {
      driver = "docker"

      vault {}

      [[ template "docker_config" . ]]
    }

    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }
  }

  update {
    max_parallel = 1
    min_healthy_time = "10s"
    healthy_deadline = "5m"
    auto_revert = false
    canary = 0
  }
}
