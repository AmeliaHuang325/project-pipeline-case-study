# Supabase PostgreSQL connection using credentials from environment variables.
#
# .Renviron:
#   SUPABASE_DB_HOST=...
#   SUPABASE_DB_PORT=6543
#   SUPABASE_DB_NAME=postgres
#   SUPABASE_DB_USER=...
#   SUPABASE_DB_PASSWORD=...
#   SUPABASE_DB_SSLMODE=require

library(DBI)
library(RPostgres)

connect_db <- function() {
  required <- c("SUPABASE_DB_HOST", "SUPABASE_DB_USER", "SUPABASE_DB_PASSWORD")
  missing  <- required[Sys.getenv(required) == ""]
  if (length(missing) > 0) stop("Missing environment variables: ", paste(missing, collapse = ", "))

  dbConnect(
    Postgres(),
    host     = Sys.getenv("SUPABASE_DB_HOST"),
    port     = as.integer(Sys.getenv("SUPABASE_DB_PORT", "6543")),
    dbname   = Sys.getenv("SUPABASE_DB_NAME", "postgres"),
    user     = Sys.getenv("SUPABASE_DB_USER"),
    password = Sys.getenv("SUPABASE_DB_PASSWORD"),
    sslmode  = Sys.getenv("SUPABASE_DB_SSLMODE", "require")
  )
}

# Usage:
# con <- connect_db()
# shiny::onStop(function() DBI::dbDisconnect(con))
