library(DBI)
library(dotenv)

con <- dbConnect(
  RPostgres::Postgres(),
  dbname   = Sys.getenv("DB_NAME"),
  host     = Sys.getenv("DB_HOST"),
  port     = 5432,
  user     = Sys.getenv("DB_NAME"),
  password = Sys.getenv("DB_PASS")
  )

on.exit(dbDisconnect(con))



#' @filter cors
cors <- function(req, res) {

  res$setHeader("Access-Control-Allow-Origin", "*")

  if (req$REQUEST_METHOD == "OPTIONS") {
    res$setHeader("Access-Control-Allow-Methods","*")
    res$setHeader("Access-Control-Allow-Headers", req$HTTP_ACCESS_CONTROL_REQUEST_HEADERS)
    res$status <- 200
    return(list())
  } else {
    plumber::forward()
  }

}

#' @get /
#' @post /
#' @delete /
function(req) {
  method <- req$REQUEST_METHOD

  if (method == "GET") {

  }

  if (method == "POST") {

  }

  if (method == "DELETE") {

  }
}


#' @get /<id>
#' @patch /<id>
#' @delete /<id>
function(id) {
  method <- req$REQUEST_METHOD

  if (method == "GET") {

  }

  if (method == "PATCH") {

  }

  if (method == "DELETE") {

  }
}
