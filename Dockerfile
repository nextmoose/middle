ARG DOCKER_SEMVER=18.01.0
FROM docker:${DOCKER_SEMVER}-ce
RUN \
    apk add --no-cache coreutils && \
        apk add --no-cache util-linux && \
        adduser -D user && \
        rm -rf /var/cache/apk/*
USER user
VOLUME /home
WORKDIR /home/user
COPY entrypoint.sh /home/user/
ENV DOCKER_SEMVER=${DOCKER_SEMVER}
ENV BROWSER_SEMVER=0.0.0
ENV INNER_SEMVER=0.0.0
ENTRYPOINT ["sh", "/home/user/entrypoint.sh"]
CMD []