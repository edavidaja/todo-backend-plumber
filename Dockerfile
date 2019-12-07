FROM rocker/r-ubuntu:18.04
RUN apt-get update -qq && \
    apt-get dist-upgrade -y && \
    apt-get install r-cran-plumber r-cran-rpostgres -y
COPY . /app
WORKDIR /app
EXPOSE 8080
ENTRYPOINT ["R", "-e", "pr <- plumber::plumb('/app/plumber.R'); pr$run(host='0.0.0.0', port=as.numeric(Sys.getenv('PORT', 8080)))"]

