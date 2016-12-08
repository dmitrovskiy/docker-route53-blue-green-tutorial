#!/bin/bash

set -e
set -a

. "~conf.env"

echo ">> PRODUCTION - $PRODUCTION"
echo ">> SAFE - $SAFE"

# Turning off exception exit temporary
set +e
# Starting SAFE environment
echo ">> Starting SAFE environment ... "
docker-machine start "my-app-$ENV-$SAFE"
docker-machine regenerate-certs -f "my-app-$ENV-$SAFE"
set -e

echo ">> Deploying to SAFE environment - $SAFE"
VERSIONS_CONFIG_FILE=${VERSIONS_CONFIG_FILE:-"~conf.versions.$SAFE"}
echo ">> Versions file: $VERSIONS_CONFIG_FILE"

if ! [[ -f $VERSIONS_CONFIG_FILE ]]
then
    echo "Versions file $VERSIONS_CONFIG_FILE doesn't exist"
    exit 1
fi

. $VERSIONS_CONFIG_FILE

eval $(docker-machine env "my-app-$ENV-$SAFE")
eval $(aws ecr get-login --region us-east-1)

export ENV_MACHINE_TYPE=$SAFE

docker-compose pull
docker-compose up -d

echo ">> Updating versions file ... "

echo "#!/bin/bash" > $VERSIONS_CONFIG_FILE
echo "export APP_VERSION=\${APP_VERSION:-$APP_VERSION}" >> $VERSIONS_CONFIG_FILE

