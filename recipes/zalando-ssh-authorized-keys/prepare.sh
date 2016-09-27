#!/bin/bash
set -e

[ -d ~/.ssh/ ] || mkdir ~/.ssh/
# this deploy key has to be added manually and should not appear in the repo
cp $(dirname $0)/ssh-authorized-keys-deploy ~/.ssh/id_rsa
echo 'StrictHostKeyChecking no' > ~/.ssh/config
chmod 600 ~/.ssh/
chmod 400 ~/.ssh/id_rsa

