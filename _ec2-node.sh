#!/bin/bash

set -e
set -a

if [[ -z $1 ]]
then
    echo "Wrong script usage. Need a node name"
    exit 1
fi

NODE_NAME=$1

. "~conf.env"

echo ">> Removing my-app-$ENV-$NODE_NAME ..."
docker-machine rm -f "my-app-$ENV-$NODE_NAME"

echo ">> Creating my-app-$ENV-$NODE_NAME ..."
docker-machine --native-ssh create \
    -d amazonec2 \
    --amazonec2-instance-type="t2.micro" \
    "my-app-$ENV-$NODE_NAME"

