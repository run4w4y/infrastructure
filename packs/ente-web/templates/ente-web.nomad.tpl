job [[ .my.job_name | quote ]] {
  datacenters = [[ .my.datacenters | toStringList ]]
  type = "service"

  group "ente-web" {
    count = [[ .my.count ]]

    network {
      mode = "bridge"

      port "gateway" {
        to = 3005
      }

      [[ range list "photos" "accounts" "auth" "cast" "albums" ]]
      port [[ . | quote ]] {
        to = [[ index $.my.ports . ]]
      }
      [[ end ]]
    }

    [[ $ports := .my.ports ]]
    [[ $subdomains := .my.subdomains ]]
    [[ $sidecar_resources := .my.sidecar_resources ]]
    service {
      name = "ente-web"
      task = "ente-web-gateway"
      port = "3005"

      tags = [
        "traefik.enable=true",
        "traefik.consulcatalog.connect=true",
        [[ range list "albums" "photos" "accounts" "auth" "cast" ]]
        "traefik.http.routers.ente-web-[[ . ]].rule=Host(`[[ index $subdomains . ]].[[ $.my.primary_domain ]]`)",
        "traefik.http.routers.ente-web-[[ . ]].entrypoints=web",
        "traefik.http.routers.ente-web-[[ . ]].service=ente-web",
        [[ end ]]
      ]

      check {
        name     = "ente-web-gateway-http"
        task     = "ente-web-gateway"
        type     = "http"
        port     = "gateway"
        path     = "/healthz"
        interval = "15s"
        timeout  = "3s"
        expose   = true

      }

      connect {
        sidecar_service {}
        sidecar_task {
          resources {
            cpu    = [[ $sidecar_resources.cpu ]]
            memory = [[ $sidecar_resources.memory ]]
          }
        }
      }
    }

    task "ente-web-gateway" {
      driver = "docker"

      service {
        name = "ente-web-gateway-health"
        port = "gateway"
        tags = ["traefik.enable=false"]

        check {
          name     = "ente-web-gateway-liveness"
          type     = "http"
          path     = "/healthz"
          interval = "15s"
          timeout  = "3s"

          check_restart {
            limit = 3
            grace = "30s"
          }
        }
      }

      config {
        image   = [[ .my.gateway_image | quote ]]
        command = "nginx"
        args    = ["-c", "/local/nginx.conf", "-g", "daemon off;"]
      }

      template {
        destination = "local/nginx.conf"
        change_mode = "restart"
        data = <<EOH
worker_processes 1;
pid /tmp/nginx.pid;
error_log /dev/stderr warn;
events { worker_connections 512; }
http {
  access_log off;
  server_tokens off;
  keepalive_timeout 15s;
  client_body_temp_path /tmp/client_temp;
  proxy_temp_path /tmp/proxy_temp;
  proxy_http_version 1.1;
  proxy_set_header Connection "";
  proxy_set_header Host $http_host;
  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  proxy_set_header X-Forwarded-Proto $http_x_forwarded_proto;
  proxy_buffering off;

  server {
    listen 3005 default_server;
    server_name _;
    location = /healthz { return 200 "ok\n"; }
    location / { return 421; }
  }
  [[ range list "albums" "photos" "accounts" "auth" "cast" ]]
  upstream [[ . ]] {
    server 127.0.0.1:[[ index $ports . ]];
    keepalive 2;
  }
  server {
    listen 3005;
    server_name [[ index $subdomains . ]].[[ $.my.primary_domain ]];
    location / { proxy_pass http://[[ . ]]; }
  }
  [[ end ]]
}
EOH
      }

      resources {
        cpu    = [[ .my.gateway_resources.cpu ]]
        memory = [[ .my.gateway_resources.memory ]]
      }
    }

    [[ range list "photos" "accounts" "auth" "cast" "albums" ]]
    task "ente-web-[[ . ]]" {
      driver = "docker"

      service {
        name = "ente-web-[[ . ]]"
        port = [[ . | quote ]]
        tags = ["traefik.enable=false"]

        check {
          name     = "ente-web-[[ . ]]-http"
          type     = "http"
          path     = [[ if eq . "photos" ]]"/gallery"[[ else ]]"/"[[ end ]]
          interval = "15s"
          timeout  = "3s"

          check_restart {
            limit = 3
            grace = "30s"
          }
        }
      }

      config {
        image = "[[ $.my.docker_image_registry_url | trimSuffix "/" ]]/[[ $.my.docker_image_name ]]:[[ $.my.docker_image_tag ]]"
        command = "/usr/local/bin/serve"
        args = [
          "/app/[[ if eq . "albums" ]]photos[[ else ]][[ . ]][[ end ]]",
          "-l", "tcp://0.0.0.0:[[ index $ports . ]]"
        ]

        auth = {
          [[ if empty $.my.docker_image_username | not -]]
          username = [[ $.my.docker_image_username | quote ]]
          [[- end ]]
          [[ if empty $.my.docker_image_password | not -]]
          password = [[ $.my.docker_image_password | quote ]]
          [[- end ]]
        }
      }

      resources {
        cpu    = [[ $.my.resources.cpu ]]
        memory = [[ $.my.resources.memory ]]
      }
    }
    [[ end ]]

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
