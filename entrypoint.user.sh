#!/bin/sh

cleanup(){
    /usr/local/bin/docker container stop browser inner &&
        /usr/local/bin/docker container prune --force &&
        /usr/local/bin/docker network prune --force &&
        /usr/local/bin/docker volume prune --force
} &&
    trap cleanup EXIT &&
    /usr/local/bin/docker container prune --force &&
    /usr/local/bin/docker network prune --force &&
    /usr/local/bin/docker volume prune --force &&
    /usr/local/bin/docker \
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
    /usr/local/bin/docker \
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
        --mount type=bind,source=/opt/cloud9/workspace,destination=/opt/cloud9/workspace,readonly=false \
        --mount type=bind,source=/srv/host/tmp/.X11-unix,destination=/tmp/.X11-unix,readonly=true \
        --label expiry=$(date --date "now + 1 month" +%s) \
        rebelplutonium/inner:${INNER_SEMVER} &&
    /usr/local/bin/docker network create main &&
    /usr/local/bin/docker network connect main browser &&
    /usr/local/bin/docker network connect --alias inner main inner &&
    /usr/local/bin/docker container start browser &&
    /usr/local/bin/docker container start --interactive inner
