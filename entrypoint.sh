#!/bin/sh

docker \
    container \
    create \
    --name browser \
    --privileged \
    --mount type=bind,source=/tmp/.X11-unix,destination=/tmp/.X11-unix,readonly=true \
    --shm-size 256m \
    --label expiry=$(date --date "now + 1 month" +%s) \
    rebelplutonium/browser:${BROWSER_VERSION} \
        http://hacker:13912 &&
    docker \
        container \
        create \
        --name inner \
        --env CLOUD9_PORT=10703 \
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
        --mount type=bind,source=/tmp/.X11-unix,destination=/tmp/.X11-unix,readonly=true \
        --mount type=bind,source=/var/run/docker.sock,destination=/var/run/docker.sock,readonly=true \
        --label expiry=$(date --date "now + 1 month" +%s) \
        rebelplutonium/inner:${INNER_VERSION}
