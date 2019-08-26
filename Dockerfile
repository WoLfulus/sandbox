FROM docker:stable

RUN apk --update add --no-cache bash git

ENV SANDBOX="true"
ENV PATH="$PATH:/sandbox/bin/"

WORKDIR /sandbox/

COPY ./rootfs/ /
RUN chmod +x /usr/bin/entrypoint

ENTRYPOINT [ "/usr/bin/entrypoint" ]
