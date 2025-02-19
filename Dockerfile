FROM posit/r-base:4.3-noble
COPY . /app
WORKDIR /app
RUN R -e "options(repos = c(CRAN ='https://p3m.dev/cran/__linux__/manylinux_2_28/latest'));install.packages('renv');renv::restore(repos = c(CRAN ='https://p3m.dev/cran/__linux__/manylinux_2_28/latest'))"
EXPOSE 8080
ENTRYPOINT ["Rscript", "./start.R"]
