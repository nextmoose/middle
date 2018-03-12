#!/bin/sh

usermod -u ${TARGET_UID} user &&
    su -c "sh /opt/script/entrypoint.user.sh"