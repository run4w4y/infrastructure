# read the postgres root user credentials from the vault

data "vault_kv_secret_v2" "postgres_secret" {
  mount = "secret"
  name  = "postgres/root-credentials"
}

# create the ente user credentials

resource "random_password" "ente_postgres" {
  length = 32
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
