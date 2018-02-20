#!/bin/sh

cleanup(){
    docker container stop browser inner &&
        docker container rm -fv browser inner &&
        docker network rm main &&
        docker volume rm docker
} &&
    trap cleanup EXIT &&
    docker \
        container \
        create \
        --name browser \
        --privileged \
        --mount type=bind,source=/srv/host/tmp/.X11-unix,destination=/tmp/.X11-unix,readonly=true \
        --shm-size 256m \
        --label expiry=$(date --date "now + 1 month" +%s) \
        --env DISPLAY="${DISPLAY}" \
        rebelplutonium/browser:${BROWSER_SEMVER} \
            http://inner:10604 &&
    docker \
        container \
        create \
        --name inner \
        --env CLOUD9_PORT \
        --env PROJECT_NAME \
        --env USER_NAME \
        --env USER_EMAIL \
        --env GPG_SECRET_KEY \
        --env GPG2_SECRET_KEY \
        --env GPG_OWNER_TRUST \
        --env GPG2_OWNER_TRUST \
        --env GPG_KEY_ID \
        --env SECRETS_ORGANIZATION \
        --env SECRETS_REPOSITORY \
        --env DOCKER_SEMVER \
        --env DOCKER_HOST \
        --mount type=bind,source=/srv/host/tmp/.X11-unix,destination=/tmp/.X11-unix,readonly=true \
        --mount type=bind,source=/srv/host/var/run/docker.sock,destination=/var/run/docker.sock,readonly=true \
        --mount type=bind,source=/srv,destination=/srv,readonly=false \
        --label expiry=$(date --date "now + 1 month" +%s) \
        rebelplutonium/inner:${INNER_SEMVER} &&
    docker network create main &&
    docker network connect main browser &&
    docker network connect --alias inner main inner &&
    docker container start browser &&
    docker container start --interactive inner
