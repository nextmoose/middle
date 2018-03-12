#!/bin/sh

cleanup(){
    echo CLEANING UP &&
        docker container stop browser inner &&
        docker container prune --force &&
        docker network prune --force &&
        docker volume prune --force
} &&
    trap cleanup EXIT &&
    sh &&
    which docker &&
    echo PREPPING &&
    docker container prune --force &&
    docker network prune --force &&
    docker volume prune --force &&
    echo CREATING THE BROWSER &&
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
    echo CREATING INNER &&
    docker \
        container \
        create \
        --name inner \
        --privileged \
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
        --env DISPLAY \
        --env TARGET_UID \
        --env XDG_RUNTIME_DIR=/var/run/${TARGET_UID} \
        --mount type=bind,source=/srv/pulse,target=/run/user/${TARGET_UID}/pulse,readonly=false \
        --mount type=bind,source=/opt/cloud9/workspace,destination=/opt/cloud9/workspace,readonly=false \
        --mount type=bind,source=/srv/host/tmp/.X11-unix,destination=/tmp/.X11-unix,readonly=true \
        --mount type=bind,source=/srv/host/var/run/docker.sock,destination=/var/run/docker.sock,readonly=true \
        --mount type=bind,source=/srv,destination=/srv,readonly=false \
        --label expiry=$(date --date "now + 1 month" +%s) \
        rebelplutonium/inner:${INNER_SEMVER} &&
    echo LINKING &&
    docker network create main &&
    docker network connect main browser &&
    docker network connect --alias inner main inner &&
    echo STARTING &&
    docker container start browser &&
    docker container start --interactive inner
