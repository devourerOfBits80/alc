#!/bin/sh

# add default ~/.ssh/id_rsa key
ssh-add -q < /dev/null

# add ~/.ssh/id_rsa and ~/.ssh/id_ed25519 keys
#ssh-add -q ~/.ssh/id_rsa ~/.ssh/id_ed25519 < /dev/null
