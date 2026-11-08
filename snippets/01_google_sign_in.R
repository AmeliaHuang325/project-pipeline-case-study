# Google Sign-In: verify the ID token server-side, then look up the user's
# role in the access-list Google Sheet (read with a service account).
#
# Environment variables:
#   GOOGLE_CLIENT_ID                     OAuth client ID
#   GOOGLE_SHEETS_SERVICE_ACCOUNT_PATH   service-account JSON key
#   ACCESS_LIST_SHEET_ID                 access-list sheet ID

library(shiny)
library(httr)
library(googlesheets4)

# Sheets API auth via service account
gs4_auth(path = Sys.getenv("GOOGLE_SHEETS_SERVICE_ACCOUNT_PATH"))

ROLE_MAP <- c(Admin = "admin", Editor = "editor", Contributor = "contributor")

verify_google_token <- function(id_token) {
  res <- tryCatch(
    GET("https://oauth2.googleapis.com/tokeninfo", query = list(id_token = id_token)),
    error = function(e) NULL
  )
  if (is.null(res) || status_code(res) != 200) return(NULL)

  claims <- content(res)
  issued_for_this_app <- identical(claims$aud, Sys.getenv("GOOGLE_CLIENT_ID"))
  email_verified      <- identical(claims$email_verified, "true")

  if (issued_for_this_app && email_verified) claims else NULL
}

lookup_role <- function(email) {
  access <- read_sheet(Sys.getenv("ACCESS_LIST_SHEET_ID"), col_types = "c")
  match  <- access[tolower(trimws(access$email)) == tolower(trimws(email)), ]
  if (nrow(match) == 0) return(NULL)

  role <- unname(ROLE_MAP[trimws(match$access_level[1])])
  if (is.na(role)) return(NULL)

  list(role = role, name = match$full_name[1] %||% email)
}

login_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    user <- reactiveVal(NULL)

    observeEvent(input$id_token, {
      claims <- verify_google_token(input$id_token)
      if (is.null(claims)) {
        showNotification("Could not verify your Google sign-in.", type = "error")
        return()
      }

      access <- lookup_role(claims$email)
      if (is.null(access)) {
        showNotification("Your account does not have access. Please contact an administrator.",
                         type = "warning")
        return()
      }

      user(list(email = claims$email, name = access$name, role = access$role))
    })

    user
  })
}
