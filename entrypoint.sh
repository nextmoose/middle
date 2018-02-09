#!/bin/sh

docker volume create docker &&
    docker \
        container \
        create \
        --name browser \
        --privileged \
        --mount type=bind,source=/srv/host/tmp/.X11-unix,destination=/tmp/.X11-unix,readonly=true \
        --mount type=volume,source=docker,destination=/srv/docker,readonly=false \
        --mount type=bind,source=/srv/host/dev/vboxdrv,destination=/dev/vboxdrv,readonly=true \
        --mount type=bind,source=/srv/host/dev/vboxnetctl,destination=/dev/vboxnetctl,readonly=true \
        --shm-size 256m \
        --label expiry=$(date --date "now + 1 month" +%s) \
        --env DISPLAY="${DISPLAY}" \
        rebelplutonium/browser:${BROWSER_SEMVER} \
            http://inner:13912 &&
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
        --env DISPLAY \
        --env DOCKER_HOST=tcp://docker:2376 \
        --mount type=bind,source=/srv/host/tmp/.X11-unix,destination=/tmp/.X11-unix,readonly=true \
        --mount type=bind,source=/srv/host/dev/vboxdrv,destination=/dev/vboxdrv,readonly=true \
        --mount type=bind,source=/srv/host/dev/vboxnetctl,destination=/dev/vboxnetctl,readonly=true \
        --mount type=volume,source=docker,destination=/srv/docker,readonly=false \
        --label expiry=$(date --date "now + 1 month" +%s) \
        rebelplutonium/inner:${INNER_SEMVER} &&
    docker network create main &&
    docker network connect main browser &&
    docker network connect --alias inner main inner &&
    docker container start browser inner &&
    sh
