library(plumber)
library(pool)

con <-
  dbPool(
    drv      = RPostgres::Postgres(),
    dbname   = Sys.getenv("DB_NAME"),
    host     = Sys.getenv("DB_HOST"),
    port     = Sys.getenv("DB_PORT"),
    user     = Sys.getenv("DB_NAME"),
    password = Sys.getenv("DB_PASS")
  )

plumb("plumber.R") |>
  pr_hook("exit", function() {
    poolClose(con)
  }) |>
  pr_run(
    host = "0.0.0.0",
    port = as.numeric(Sys.getenv("PORT", 8080))
  )
