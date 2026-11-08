# Export tables to a timestamped CSV folder (run by 05_backup_workflow.yml).

library(DBI)
library(RPostgres)
library(readr)

source("snippets/04_db_connection.R")

TABLES <- c("projects", "audit_log")

con <- connect_db()
on.exit(dbDisconnect(con), add = TRUE)

out_dir <- paste0("backup_", format(Sys.time(), "%Y-%m-%d_%H-%M-%S", tz = "UTC"))
dir.create(out_dir)

for (tbl in TABLES) {
  data <- dbReadTable(con, tbl)
  write_csv(data, file.path(out_dir, paste0(tbl, ".csv")))
  message(sprintf("Exported %-10s %5d rows", tbl, nrow(data)))
}
