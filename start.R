library(plumber)
library(pool)

con <- dbPool(drv = RPostgres::Postgres())

plumb("plumber.R") |>
  pr_hook("exit", function() {
    poolClose(con)
  }) |>
  pr_run(
    host = "0.0.0.0",
    port = as.numeric(Sys.getenv("PORT", 8080))
  )
