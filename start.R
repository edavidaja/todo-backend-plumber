library(plumber)
library(pool)

con <-
  dbPool(
    drv      = RPostgres::Postgres(),
    dbname   = Sys.getenv("DB_NAME"),
    host     = Sys.getenv("DB_HOST"),
    port     = 5432,
    user     = Sys.getenv("DB_NAME"),
    password = Sys.getenv("DB_PASS"),
    maxSize  = 5 # connection limit for elephantsql instance class
  )

pr <- plumb("plumber.R")

pr$registerHook("exit", function() {
  poolClose(con)
})

pr$run(
  host = "0.0.0.0",
  port = as.numeric(Sys.getenv("PORT", 8080))
  )
