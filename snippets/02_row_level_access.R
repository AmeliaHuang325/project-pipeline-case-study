# Row-level access: admins and editors see all projects, contributors see only
# projects where they are listed as a lead.

LEAD_COLUMNS <- c("lead", "co_lead", "partner_lead", "project_director")

filter_rows_for_user <- function(df, user_name) {
  if (nrow(df) == 0 || is.null(user_name) || !nzchar(user_name)) return(df[0, ])

  cols <- intersect(LEAD_COLUMNS, names(df))
  if (length(cols) == 0) return(df[0, ])

  target <- tolower(trimws(user_name))
  keep <- Reduce(`|`, lapply(cols, function(col) {
    hit <- tolower(trimws(df[[col]])) == target
    hit[is.na(hit)] <- FALSE
    hit
  }))

  df[keep, , drop = FALSE]
}

visible_projects <- function(df, user) {
  switch(user$role,
    admin       = df,
    editor      = df,
    contributor = filter_rows_for_user(df, user$name),
    df[0, ]
  )
}

# Example:
# projects <- DBI::dbGetQuery(con, "SELECT * FROM projects")
# visible_projects(projects, list(role = "contributor", name = "Jordan Lee"))
