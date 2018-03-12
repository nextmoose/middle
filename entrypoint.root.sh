#!/bin/sh

usermod -u ${TARGET_UID} user &&
    su -c "sh /opt/scripts/entrypoint.user.sh"