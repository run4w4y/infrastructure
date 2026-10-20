variable "job_name" {
  description = "The name of the job"
  type        = string
  default     = "ente-web"
}

variable "datacenters" {
  description = "A list of datacenters in the region which are eligible for task placement."
  type        = list(string)
  default     = ["dc1"]
}

variable "ports" {
  description = "Ports on which the container serves each of the Ente web applications"
  type = object({
    photos   = number
    accounts = number
    auth     = number
    cast     = number
    albums   = number
  })
  default = {
    photos   = 3000
    accounts = 3001
    auth     = 3002
    cast     = 3003
    albums   = 3004
  }
}

variable "subdomains" {
  description = "Mapping of the webapp to a subdomain in traefik"
  type = object({
    photos   = string
    accounts = string
    auth     = string
    cast     = string
    albums   = string
  })
  default = {
    photos   = "ente"
    accounts = "ente-accs"
    auth     = "ente-auth"
    cast     = "ente-cast"
    albums   = "ente-albums"
  }
}

variable "count" {
  description = "The number of replicas to be deployed"
  type        = number
  default     = 1
}

variable "docker_image_registry_url" {
  description = "URL to the Docker registry"
  type        = string
  default     = "ghcr.io"
}

variable "docker_image_name" {
  description = "Docker image name"
  type        = string
  default     = "ente-web"
}

variable "docker_image_tag" {
  description = "Docker image tag"
  type        = string
  default     = "latest"
}

variable "docker_image_username" {
  description = "Username to log in to the Docker registry with"
  type        = string
  default     = "gitlab-ci-token"
}

variable "docker_image_password" {
  description = "Password to log in to the Docker registry with"
  type        = string
  default     = null
}

variable "resources" {
  description = "Resources assigned to each of the five web server tasks per replica"
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 20,
    memory = 128
  }
}

variable "sidecar_resources" {
  description = "Resources assigned to the shared Connect sidecar"
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 50
    memory = 64
  }
}

variable "primary_domain" {
  description = "Domain used by the five public web routes"
  type        = string
  default     = "example.com"
}

variable "gateway_image" {
  description = "Pinned Nginx image used to route the shared mesh endpoint to the five web tasks"
  type        = string
  default     = "nginx@sha256:970364228b1e4f932abc22d321932816782cca8a20b85a77552a7cfe9acfb3b5"
}

variable "gateway_resources" {
  description = "Resources assigned to the shared HTTP router"
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 20
    memory = 32
  }
}
