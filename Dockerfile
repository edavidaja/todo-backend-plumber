FROM rocker/r-ver:3.6.1

RUN R -e "install.packages('renv', repos = c(CRAN = 'https://cloud.r-project.org'))"
COPY . /app
WORKDIR app

RUN R -e "renv::restore(lockfile='renv.lock')"
EXPOSE 8080
ENTRYPOINT ["R", "-e", "pr <- plumber::plumb('/app/plumber.R'); pr$run(host='0.0.0.0', port=8080)"]

