#
# Go dependencies
#
FROM golang:1-alpine AS go-deps
RUN apk --update add --no-cache bash git make ca-certificates
WORKDIR /repos
ENV GO111MODULE=on GOOS=linux GOARCH=amd64 CGO_ENABLED=0
RUN mkdir /output
RUN git clone --depth 1 https://github.com/direnv/direnv.git && cd direnv && go build && mv ./direnv /output/direnv
RUN git clone --depth 1 https://github.com/wagoodman/dive.git && cd dive && go build && mv ./dive /output/dive
RUN git clone --depth 1 https://github.com/moncho/dry.git && cd dry && go build && mv ./dry /output/dry


#
# Sandcrate machine
#
FROM docker:stable

RUN apk --update add --no-cache bash git curl nano vim python3 figlet

ENV SANDBOX="true" SANDCRATE="true" PATH="$PATH:/usr/sandcrate/bin/:/usr/sandcrate/vendor"

WORKDIR /sandcrate/

# Python
RUN if [ ! -e /usr/bin/python ]; then ln -sf python3 /usr/bin/python ; fi && \
    python -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --no-cache --upgrade pip setuptools wheel pipenv && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi

# Additional files
RUN mkdir -p /usr/sandcrate/include && \
    curl -L -o /usr/sandcrate/include/argsf https://raw.githubusercontent.com/WoLfulus/argsf/master/src/argsf.sh

# Files
COPY ./rootfs/ /
COPY --from=go-deps /output/ /usr/sandcrate/bin/

# Permissions
RUN find /usr/sandcrate/bin/ -type f -exec chmod +x {} \; && \
    chmod +x /usr/bin/entrypoint

ENTRYPOINT [ "/usr/bin/entrypoint" ]
