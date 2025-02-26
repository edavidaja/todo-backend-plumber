FROM posit/r-base:4.3-noble
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y libpq-dev libsodium-dev
COPY . /app
WORKDIR /app
RUN R -e "options(repos = c(CRAN ='https://p3m.dev/cran/__linux__/noble/latest'));install.packages('renv');renv::restore(repos = c(CRAN ='https://p3m.dev/cran/__linux__/noble/latest'))"
EXPOSE 8080
ENTRYPOINT ["Rscript", "./start.R"]
