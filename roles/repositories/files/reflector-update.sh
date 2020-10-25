#!/bin/bash

/usr/bin/reflector --verbose \
                   --latest 20 \
                   --protocol https \
                   --age 24 \
                   --sort rate \
                   --save /etc/pacman.d/mirrorlist

PACNEW_FILE="/etc/pacman.d/mirrorlist.pacnew"
if [ -f "$PACNEW_FILE" ]; then
    rm -f $PACNEW_FILE
fi
