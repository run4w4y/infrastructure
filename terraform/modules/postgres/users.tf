# ente postgres role / user

resource "postgresql_role" "ente" {
  name            = "ente"
  login           = true
  password        = random_password.ente_postgres.result
  superuser       = false
  create_database = false
  create_role     = false
  inherit         = true
  replication     = false
}

# grant connect to the ente database

resource "postgresql_grant" "ente_connect" {
  database    = postgresql_database.ente.name
  role        = postgresql_role.ente.name
  object_type = "database"
  privileges  = ["CONNECT"]
}

# grant public schema usage

resource "postgresql_grant" "ente_schema_usage" {
  database    = postgresql_database.ente.name
  schema      = "public"
  role        = postgresql_role.ente.name
  object_type = "schema"
  privileges  = ["USAGE"]
}

# grant access to any existing tables in the public schema

resource "postgresql_grant" "ente_tables" {
  database    = postgresql_database.ente.name
  schema      = "public"
  role        = postgresql_role.ente.name
  object_type = "table"
  privileges  = ["ALL"]
}
