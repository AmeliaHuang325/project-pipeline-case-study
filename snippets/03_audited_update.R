# Update one project field and write the change to audit_log in a single
# transaction. Column names can't be bound as parameters, so `field` is checked
# against an allowlist and quoted before use.

library(DBI)

EDITABLE_FIELDS <- c("status", "funder", "probability", "budget_remaining",
                     "lead", "co_lead", "notes")

update_project_field <- function(con, project_id, field, new_value, changed_by) {
  if (!field %in% EDITABLE_FIELDS) stop("Field is not editable: ", field)

  column <- dbQuoteIdentifier(con, field)

  dbWithTransaction(con, {
    old_value <- dbGetQuery(
      con,
      paste0("SELECT ", column, " AS value FROM projects WHERE id = $1"),
      params = list(project_id)
    )$value

    dbExecute(
      con,
      paste0("UPDATE projects SET ", column, " = $1, last_updated_at = CURRENT_DATE WHERE id = $2"),
      params = list(new_value, project_id)
    )

    dbExecute(
      con,
      "INSERT INTO audit_log (project_id, field, old_value, new_value, changed_by)
       VALUES ($1, $2, $3, $4, $5)",
      params = list(project_id, field, as.character(old_value), as.character(new_value), changed_by)
    )
  })
}

# Usage in the Shiny server:
# observeEvent(input$cell_edit, {
#   e <- input$cell_edit
#   update_project_field(con, e$id, e$field, e$value, changed_by = user()$name)
# })
