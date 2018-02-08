ARG DOCKER_VERSION=18.01.0
FROM docker:${DOCKER_VERSION}-ce
RUN \
    apk add --no-cache coreutils && \
        apk add --no-cache util-linux && \
        adduser -D user && \
        rm -rf /var/cache/apk/*
USER user
VOLUME /home
WORKDIR /home/user
COPY entrypoint.sh /home/user/
ENV DOCKER_VERSION=${DOCKER_VERSION}
ENV BROWSER_VERSION=0.0.0
ENV INNER_VERSION=0.0.0
ENTRYPOINT ["sh", "/home/user/entrypoint.sh"]
CMD []