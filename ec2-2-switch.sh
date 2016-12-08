#!/bin/bash

set -e
set -a

. "~conf.env"

echo ">> PRODUCTION - $PRODUCTION"
echo ">> SAFE - $SAFE"
echo ">> Switching production to $SAFE"

eval $(aws ecr get-login --region us-east-1)

ZONE_ID=$(aws route53 list-hosted-zones | jq -r '.HostedZones | .[] | select(.Name == "test.com.") | .Id')
DPL_IP_ADDRESS=$(docker-machine ip "my-app-$ENV-$SAFE")
DPL_ENV=$ENV

rm -f ~conf.route53.changes.template
cp _conf.route53.changes.template ~conf.route53.changes.template

sed -i "s|%ENV%|$DPL_ENV|g" ~conf.route53.changes.template
sed -i "s|%IP_ADDRESS%|$DPL_IP_ADDRESS|g" ~conf.route53.changes.template

aws route53 change-resource-record-sets --hosted-zone-id $ZONE_ID --change-batch "file://$(pwd)/~conf.route53.changes.template"

echo ">> Updating ~conf.env"

echo "#!/bin/bash" > "~conf.env"
echo "export ENV=\"$ENV\"" >> "~conf.env"
echo "export PRODUCTION=\"$SAFE\"" >> "~conf.env"
echo "export SAFE=\"$PRODUCTION\"" >> "~conf.env"

