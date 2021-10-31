FROM rocker/r-ubuntu:20.04
RUN apt-get update -qq && \
    apt-get dist-upgrade -y
RUN apt-get install r-cran-plumber r-cran-rpostgres r-cran-pool -y
RUN install2.r zeallot
COPY . /app
WORKDIR /app
EXPOSE 8080
ENTRYPOINT ["Rscript", "./start.R"]

