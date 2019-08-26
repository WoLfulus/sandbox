#
# Direnv builder
#
FROM golang:1-alpine AS builder
RUN apk --update add --no-cache bash git make
RUN git clone https://github.com/direnv/direnv.git && cd direnv && \
    make install DESTDIR=/usr

#
# Sandbox machine
#
FROM docker:stable

RUN apk --update add --no-cache bash git curl nano vim python3

ENV SANDBOX="true"
ENV PATH="$PATH:/usr/sandbox/bin/"

WORKDIR /sandbox/

# Files
COPY ./rootfs/ /
COPY --from=builder /usr/bin/direnv /usr/bin/direnv

# Python
RUN if [ ! -e /usr/bin/python ]; then ln -sf python3 /usr/bin/python ; fi && \
    python -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --no-cache --upgrade pip setuptools wheel pipenv && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi

# Additional files
RUN curl -L -o /usr/sandbox/argsf.sh https://raw.githubusercontent.com/WoLfulus/argsf/master/src/argsf.sh

# Permissions
RUN find /usr/sandbox/bin/ -type f -exec chmod +x {} \; && \
    chmod +x /usr/bin/entrypoint && \
    chmod +x /usr/bin/direnv

ENTRYPOINT [ "/usr/bin/entrypoint" ]
