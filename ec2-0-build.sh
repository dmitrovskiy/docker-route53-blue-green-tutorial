#!/bin/bash

set -e

echo ">> Initiating ~conf.env ..."
rm -f ~conf.env
cp _conf.env ~conf.env

echo ">> Initiating ~conf.versions.blue & ~conf.versions.green"

rm -f ~conf.versions.blue ~conf.versions.green
cp _conf.versions.default ~conf.versions.blue
cp _conf.versions.default ~conf.versions.green

echo ">> Recreating BLUE & GREEN environment ..."

./_ec2-node.sh blue &
./_ec2-node.sh green &
wait

docker-machine ls
