library(DBI)
library(zeallot)

con <- dbConnect(
  RPostgres::Postgres(),
  dbname   = Sys.getenv("DB_NAME"),
  host     = Sys.getenv("DB_HOST"),
  port     = 5432,
  user     = Sys.getenv("DB_NAME"),
  password = Sys.getenv("DB_PASS")
)

`%||%` <- function(l, r) { if (is.null(l)) r else l }

create_table <- function(con) {

  rs <- dbSendQuery(
    con,
    'CREATE TABLE IF NOT EXISTS todos (
    id SERIAL PRIMARY KEY,
    title text,
    completed boolean DEFAULT FALSE,
    "order" integer
    );'
    )
  dbClearResult(rs)
}


create_todo <- function(con, title, order, completed = FALSE) {
  dbGetQuery(con,
    'INSERT INTO todos ("title", "order", "completed") VALUES ($1, $2, $3) RETURNING *',
    params = list(title, order, completed)
  )
}

get_todo <- function(con, id) {
  dbGetQuery(
    con,
    "SELECT * FROM TODOS WHERE id = $1",
    params = list(id)
    )
}

get_todos <- function(con) {
  dbGetQuery(con, "SELECT * FROM todos")
}

update_todo <- function(con, id, title = NULL, order = NULL, completed = NULL) {
  c(old_id, old_title, old_completed, old_order) %<-%
  dbGetQuery(
    con,
    "SELECT * FROM todos WHERE id = $1",
    params = list(id)
  )

  new_title     <- title %||% old_title
  new_completed <- completed %||% old_completed
  new_order     <- order %||% old_order

  dbGetQuery(
    con,
    'UPDATE todos set "title"=$1, "order"=$2, completed=$3 WHERE id=$4 RETURNING *',
    params = list(new_title, new_order, new_completed, id)
    )
}

delete_todo <- function(con, id) {
 dbGetQuery(
   con,
   "DELETE FROM todos where id = $1",
   params = list(id)
   )
}

delete_todos <- function(con) {
  dbGetQuery(con, "DELETE FROM todos")
}

create_table(con)

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
function(req, res, title, order, completed) {
  method <- req$REQUEST_METHOD

  if (method == "POST") {
    create_todo(con, title, order, completed)
    res$status <- 201
    return()
  }

  if (method == "DELETE") {
    delete_todos(con)
    res$status <- 204
    return(list())
  }

  if (method == "GET") {
    get_todos(con)
  }

  msg <- "internal server error"
  res$status <- 500
  list(error=jsonlite::unbox(msg))
}


#' @get /<id:int>
#' @patch /<id:int>
#' @delete /<id:int>
function(req, res, id, title, order, completed) {
  method <- req$REQUEST_METHOD

  if (method == "PATCH") {
    update_todo(con, id)
  }

  if (method == "DELETE") {
    delete_todo(con, id)
  }

  if (method == "GET") {
    get_todo(con, id)
  }
}

on.exit(
  dbDisconnect(con)
)
