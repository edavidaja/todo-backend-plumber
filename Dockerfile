FROM rhub/r-minimal:4.1.1
# https://github.com/r-hub/r-minimal/blob/d3f7d23696bdadfff3e16d105f545cc9bc2fc103/examples/plumber/Dockerfile
RUN apk add --no-cache --update-cache \
        --repository http://nl.alpinelinux.org/alpine/v3.11/main \
        autoconf=2.69-r2 \
        automake=1.16.1-r0 && \
        It looks like the repository version produces a mismatch between the
        library stringi is expecting and what's on the system
        - test if just leaving everything on the system will work
        - test unpinning the repository version
    # repeat autoconf and automake (under `-t`)
    # to (auto)remove them after installation
    installr -d \
        -t "bash libsodium-dev curl-dev postgresql-dev linux-headers autoconf automake" \
        -a "libsodium libpq" \
        "plumber zeallot RPostgres pool"
COPY . /app
WORKDIR /app
EXPOSE 8080
ENTRYPOINT ["Rscript", "./start.R"]

