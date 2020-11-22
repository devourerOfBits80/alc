#!/bin/bash

USER_PROFILES_DIR=~/.config/firejail
DEFAULT_PROFILES_DIR=/etc/firejail

if [ ! -d "$USER_PROFILES_DIR" ]; then
    mkdir -p "$USER_PROFILES_DIR"
fi

for PROFILE_PATH in "$DEFAULT_PROFILES_DIR"/*.profile; do
    FILE_NAME="$(basename -- $PROFILE_PATH)"
    USER_PROFILE_PATH="$USER_PROFILES_DIR/$FILE_NAME"

    if [ ! -f "$USER_PROFILE_PATH" ]; then
        echo "include $PROFILE_PATH" > "$USER_PROFILE_PATH"
        echo "The $FILE_NAME has been included"
    fi
done
