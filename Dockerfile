FROM docker:stable

RUN apk --update add --no-cache bash git

ENV SANDBOX="true"
ENV PATH="$PATH:/sandbox/bin/"

COPY ./rootfs/ /

ENTRYPOINT [ "entrypoint" ]
