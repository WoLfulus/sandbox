FROM golang:1-alpine AS builder

RUN apk --update add --no-cache bash git make

RUN git clone https://github.com/direnv/direnv.git && cd direnv && \
    make install DESTDIR=/usr

FROM docker:stable

RUN apk --update add --no-cache bash git curl nano vim

ENV SANDBOX="true"

WORKDIR /sandbox/

COPY ./rootfs/ /
COPY --from=builder /usr/bin/direnv /usr/bin/direnv
RUN chmod +x /usr/bin/entrypoint && \
    chmod +x /usr/bin/direnv

ENTRYPOINT [ "/usr/bin/entrypoint" ]
