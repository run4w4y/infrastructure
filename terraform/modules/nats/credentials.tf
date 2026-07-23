# Read the NATS root identity created by the Vault foundation, provision client
# identities, and publish one server-only authorization record containing
# password hashes. Plaintext client credentials are stored exactly once under
# the owning Nomad job path.

data "vault_kv_secret_v2" "root_credentials" {
  mount = "secret"
  name  = "nats/root-credentials"
}

locals {
  clients = {
    cv_registry = {
      secret_path = "cv-registry/nats-credentials"
      username    = "cv-registry"
      permissions = {
        publish   = ["registry.events.>"]
        subscribe = ["_INBOX.>"]
      }
    }
    cv_listing_checker = {
      secret_path = "cv-listing-checker/nats-credentials"
      username    = "cv-listing-checker"
      permissions = {
        publish   = ["registry.events.>"]
        subscribe = ["_INBOX.>"]
      }
    }
    cv_pdf_worker = {
      secret_path = "cv-pdf-worker/nats-credentials"
      username    = "cv-pdf-worker"
      permissions = {
        publish = [
          "registry.events.>",
          "$JS.API.CONSUMER.INFO.REGISTRY_EVENTS.registry-pdf-worker",
          "$JS.API.CONSUMER.MSG.NEXT.REGISTRY_EVENTS.registry-pdf-worker",
          "$JS.ACK.REGISTRY_EVENTS.registry-pdf-worker.>",
        ]
        subscribe = ["_INBOX.>"]
      }
    }
    cv_cache_invalidator = {
      secret_path = "cv-cache-invalidator/nats-credentials"
      username    = "cv-cache-invalidator"
      permissions = {
        publish = [
          "$JS.API.CONSUMER.INFO.REGISTRY_EVENTS.registry-cache-invalidator",
          "$JS.API.CONSUMER.MSG.NEXT.REGISTRY_EVENTS.registry-cache-invalidator",
          "$JS.ACK.REGISTRY_EVENTS.registry-cache-invalidator.>",
        ]
        subscribe = ["_INBOX.>"]
      }
    }
  }
}

resource "random_password" "client" {
  for_each = local.clients

  length  = 32
  special = false
}

resource "vault_kv_secret_v2" "client" {
  for_each = local.clients

  mount = "secret"
  name  = each.value.secret_path
  data_json = jsonencode({
    username = each.value.username
    password = random_password.client[each.key].result
  })
}

resource "vault_kv_secret_v2" "server_authorization" {
  mount = "secret"
  name  = "nats/server-authorization"
  data_json = jsonencode({
    # Terraform escapes `>` as `\u003e`, while the NATS configuration parser
    # accepts only a small set of backslash escapes. Preserve wildcard subjects
    # as literal `>` characters in the JSON embedded into nats.conf.
    users_json = replace(
      jsonencode(concat(
        [
          {
            user     = jsondecode(data.vault_kv_secret_v2.root_credentials.data_json).username
            password = jsondecode(data.vault_kv_secret_v2.root_credentials.data_json).password_hash
          }
        ],
        [
          for key, client in local.clients : {
            user        = client.username
            password    = random_password.client[key].bcrypt_hash
            permissions = client.permissions
          }
        ]
      )),
      "\\u003e",
      ">"
    )
  })
}
