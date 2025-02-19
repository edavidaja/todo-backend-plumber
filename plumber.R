library(DBI)
library(zeallot)
library(pool)
library(jsonlite)

`%||%` <- function(l, r) {
  if (is.null(l)) r else l
}

create_table <- function(con) {
  pool <- poolCheckout(con)
  rs <- dbSendQuery(
    pool,
    'CREATE TABLE IF NOT EXISTS todos (
    id SERIAL PRIMARY KEY,
    title text,
    completed boolean DEFAULT FALSE,
    "order" integer,
    url text
    );'
  )
  dbClearResult(rs)
  poolReturn(pool)
}

create_todo <- function(con, req, title, order = NULL, completed = FALSE) {
  todo_order <- order %||% NA_integer_

  df <- dbGetQuery(
    con,
    'INSERT INTO todos ("title", "order", "completed") VALUES ($1, $2, $3) RETURNING *',
    params = list(title, todo_order, completed)
  )
  url <- glue::glue("{req$rook.url_scheme}://{req$HTTP_HOST}/{df$id}")

  out <- dbGetQuery(
    con,
    'UPDATE todos set "url"=$1 WHERE id=$2 RETURNING *',
    params = list(url, df$id)
  )

  unbox(out)
}

get_todo <- function(con, id) {
  out <- dbGetQuery(
    con,
    "SELECT * FROM TODOS WHERE id = $1",
    params = list(id)
  )
  unbox(out)
}

get_todos <- function(con) {
  dbGetQuery(con, "SELECT * FROM todos")
}

update_todo <- function(con, id, title = NULL, order = NULL, completed = NULL) {
  c(old_title, old_completed, old_order) %<-%
    dbGetQuery(
      con,
      'SELECT title, completed, "order" FROM todos WHERE id = $1',
      params = list(id)
    )

  new_title <- title %||% old_title
  new_completed <- completed %||% old_completed
  new_order <- order %||% old_order

  out <- dbGetQuery(
    con,
    'UPDATE todos set "title"=$1, "order"=$2, "completed"=$3 WHERE id=$4 RETURNING *',
    params = list(new_title, new_order, new_completed, id)
  )

  unbox(out)
}

delete_todo <- function(con, id) {
  dbGetQuery(
    con,
    "DELETE FROM todos where id = $1",
    params = list(id)
  )
}

delete_todos <- function(con) {
  pool <- poolCheckout(con)
  rs <- dbSendQuery(pool, "DELETE FROM todos")
  dbClearResult(rs)
  poolReturn(pool)
}

create_table(con)

#* @filter cors
cors <- function(req, res) {
  res$setHeader("Access-Control-Allow-Origin", "*")

  if (req$REQUEST_METHOD == "OPTIONS") {
    res$setHeader("Access-Control-Allow-Methods", "*")
    res$setHeader(
      "Access-Control-Allow-Headers",
      req$HTTP_ACCESS_CONTROL_REQUEST_HEADERS
    )
    res$status <- 200
    return(list())
  } else {
    plumber::forward()
  }
}

#* @get /
#* @post /
#* @delete /
function(req, res, title, order = NULL, completed) {
  method <- req$REQUEST_METHOD

  if (method == "POST") {
    out <- create_todo(con, req, title, order)
    res$status <- 201
    return(out)
  }

  if (method == "DELETE") {
    delete_todos(con)
    res$status <- 204
    return(list())
  }

  if (method == "GET") {
    out <- get_todos(con)
    res$status <- 200
    return(out)
  }

  msg <- "something went wrong."
  res$status <- 500
  list(error = unbox(msg))
}

#* @get /<id:int>
#* @patch /<id:int>
#* @delete /<id:int>
function(req, res, id, title = NULL, order = NULL, completed = NULL) {
  method <- req$REQUEST_METHOD

  if (method == "PATCH") {
    return(update_todo(con, id, title, order, completed))
  }

  if (method == "DELETE") {
    out <- delete_todo(con, id)
    res$status <- 204
    return(out)
  }

  if (method == "GET") {
    return(get_todo(con, id))
  }

  msg <- "something went wrong."
  res$status <- 500
  list(error = unbox(msg))
}
