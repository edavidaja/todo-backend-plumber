FROM rocker/r-ver:3.6.1
RUN apt-get update -qq && \
    apt-get install -y \
    libpq-dev
COPY . /app
WORKDIR /app
RUN R -e "renv::restore(lockfile='renv.lock')"
EXPOSE 8080
ENTRYPOINT ["R", "-e", "pr <- plumber::plumb('/app/plumber.R'); pr$run(host='0.0.0.0', port=as.numeric(Sys.getenv('PORT', 8080)))"]

