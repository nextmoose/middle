#!/bin/sh

NEW_DATA_VOLUME=$(/usr/bin/docker volume create --label expiry=$(date --date "now + 1 week" +%s) --label moniker=c707b6ae-93ca-4f2f-be64-9c45508a72cb) &&
    /usr/bin/docker volume ls --quiet --filter label=moniker=c707b6ae-93ca-4f2f-be64-9c45508a72cb | while read VOLUME
    do
        /usr/bin/docker volume inspect --format "XXX {{ .Labels.expiry }} ${VOLUME} XXX" ${VOLUME}
    done | sort -n -k 1 -r &&
    /usr/bin/docker volume ls --quiet --filter label=moniker=c707b6ae-93ca-4f2f-be64-9c45508a72cb | while read VOLUME
    do
        /usr/bin/docker volume inspect --format "{{ .Labels.expiry }} ${VOLUME}" ${VOLUME}
    done | sort -n -k 1 -r | cut --fields 2 --delimiter " " | head --lines 2 | tail --lines 1 | while read OLD_DATA_VOLUME
    do
        [ ${NEW_DATA_VOLUME} != ${OLD_DATA_VOLUME} ] &&
            /usr/bin/docker \
                container \
                run \
                --interactive \
                --rm \
                --label expiry=$(date --date "now + 1 hour" +%s) \
                --volume ${OLD_DATA_VOLUME}:/input:ro \
                --volume ${NEW_DATA_VOLUME}:/output \
                alpine:3.4 \
                    cp \
                        -rp \
                        /input/. \
                        /output
    done
    docker \
        container \
        run \
        --interactive \
        --tty \
        --rm \
        --privileged \
        --mount type=volume,source=${NEW_DATA_VOLUME},destination=/data,readonly=false \
        --mount type=bind,source=/srv/host/tmp/.X11-unix,destination=/tmp/.X11-unix,readonly=true \
        --mount type=bind,source=/srv/pulse,destination=/run/user/${TARGET_UID}/pulse,readonly=false \
        --mount type=bind,source=/srv/machine-id,destination=/etc/machine-id,readonly=false \
        --mount type=bind,source=/srv/system_bus_socket,destination=/var/run/dbus/system_bus_socket,readonly=false \
        --mount type=bind,source=/srv/dbus,destination=/var/lib/dbus,readonly=false \
        --mount type=bind,source=/srv/tmp,destination=/tmp,readonly=false \
        --shm-size 256m \
        --label expiry=$(date --date "now + 1 month" +%s) \
        --env DISPLAY="${DISPLAY}" \
        --env TARGET_UID="${TARGET_UID}" \
        --env XDG_RUNTIME_DIR=/run/user/${TARGET_UID} \
        urgemerge/chromium-pulseaudio@sha256:21d8120ff7857afb0c18d4abf098549de169782e652437441c3c7778a755e46f \
            http://inner:10604
    echo NEW_DATA_VOLUME=${NEW_DATA_VOLUME}