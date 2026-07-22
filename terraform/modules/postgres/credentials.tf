# read the postgres root user credentials from the vault

data "vault_kv_secret_v2" "postgres_secret" {
  mount = "secret"
  name  = "postgres/root-credentials"
}

# create the ente user credentials

resource "random_password" "ente_postgres" {
  length  = 32
  special = false
}

resource "vault_kv_secret_v2" "ente_postgres_secret" {
  mount = "secret"
  name  = "ente/postgres-credentials"
  data_json = jsonencode({
    username = postgresql_role.ente.name
    password = random_password.ente_postgres.result
    database = postgresql_database.ente.name
  })
}

# CV application registry credentials

resource "random_password" "cv_registry_postgres" {
  length  = 32
  special = false
}

resource "vault_kv_secret_v2" "cv_registry_postgres_secret" {
  mount = "secret"
  name  = "cv-registry/postgres-credentials"
  data_json = jsonencode({
    username = postgresql_role.cv_registry.name
    password = random_password.cv_registry_postgres.result
    database = postgresql_database.cv_registry.name
  })
}

# Restricted credentials for the PDF worker.

resource "random_password" "cv_pdf_worker_postgres" {
  length  = 32
  special = false
}

resource "vault_kv_secret_v2" "cv_pdf_worker_postgres_secret" {
  mount = "secret"
  name  = "cv-pdf-worker/postgres-credentials"
  data_json = jsonencode({
    username = postgresql_role.cv_pdf_worker.name
    password = random_password.cv_pdf_worker_postgres.result
    database = postgresql_database.cv_registry.name
  })
}

# Restricted credentials for the short-lived listing-check runner.

resource "random_password" "cv_listing_checker_postgres" {
  length  = 32
  special = false
}

resource "vault_kv_secret_v2" "cv_listing_checker_postgres_secret" {
  mount = "secret"
  name  = "cv-listing-checker/postgres-credentials"
  data_json = jsonencode({
    username = postgresql_role.cv_listing_checker.name
    password = random_password.cv_listing_checker_postgres.result
    database = postgresql_database.cv_registry.name
  })
}
