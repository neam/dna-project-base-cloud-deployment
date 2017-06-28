#!/bin/bash

# Script to generate config for the 12-factor-app's docker-cloud stack

set -e

# debug
#set -x

# script path
script_path=$(dirname $0)

# Show script name and line number when errors occur to make errors easier to debug
trap 'echo "Script error in $0 on or near line ${LINENO}"' ERR

function servicename {

    local STR=$1

    # Permitted characters: [0-9,a-z,A-Z] (basic Latin letters, digits 0-9)
    STR=${STR//\//}
    STR=${STR//%/}
    STR=${STR//./}
    STR=${STR//-/}
    STR=${STR//_/}
    STR="$(echo $STR | tr '[:upper:]' '[:lower:]')" # UPPERCASE to lowercase
    # Max length 64 chars
    STR=${STR:0:64}

    echo "$STR"

}

function sedescape {

    local STR=$1

    # Permitted characters: [0-9,a-z,A-Z] (basic Latin letters, digits 0-9)
    STR="${STR/\./\.}"

    echo "$STR"

}

# create directory for deployment config

DATETIME=$(date +"%Y-%m-%d_%H%M%S")
export STACK_NAME=$(servicename "$DATETIME-$APPVHOST-$COMMITSHA")
export DEPLOYMENT_DIR="$DEPLOYMENTS_ROOT/$STACK_NAME"
mkdir -p "$DEPLOYMENT_DIR"

# export the current app config (making sure that the required config vars are set properly (tip: use your local secrets.php file to supply sensitive configuration values when deploying from locally)

export CONFIG_INCLUDE=vendor/neam/dna-project-base-cloud-deployment/deploy/generate-config.php

# dry-run config export to catch errors during the process
set +e
php -d variables_order="EGPCS" vendor/neam/php-app-config/export.php > $DEPLOYMENT_DIR/.env.tmp
if [ ! "$PHP_APP_CONFIG_EXPORTED" == "1" ]; then
  #cat $DEPLOYMENT_DIR/.env.tmp
  exit 1;
fi
set -e

# we ignore runtime-config which are set on the fly
cat $DEPLOYMENT_DIR/.env.tmp | grep -v 'export DATABASE_USER=' | grep -v 'export DATA=' | grep -v 'export DATABASE_NAME=' > $DEPLOYMENT_DIR/.env
rm $DEPLOYMENT_DIR/.env.tmp

echo
echo 'Config for '$APPVHOST':'
echo
cat $DEPLOYMENT_DIR/.env

source $DEPLOYMENT_DIR/.env

# prepare stack yml

cat stack/docker-compose-production.yml \
 | sed 's|%COMMITSHA%|'$COMMITSHA'|' \
 | sed 's|%ENV_FILE_DIR%|.|' \
 | sed 's|%APPVHOST%|'$APPVHOST'|' \
 | sed 's|%DEPLOY_STABILITY_TAG%|'$DEPLOY_STABILITY_TAG'|' \
 | sed 's|%DOCKERCLOUD_USER%|'$DOCKERCLOUD_USER'|' \
 | sed 's|%REPO%|'$REPO'|' \
 | sed 's|%VIRTUAL_HOST%|'"$(sedescape "$VIRTUAL_HOST")"'|' \
 > $DEPLOYMENT_DIR/docker-compose-production.yml

cat $DEPLOYMENT_DIR/.env \
 | grep -v '='"''" \
 | sed 's|export |    |' \
 | sed 's|='"'"'|: '"'"'|' \
 | sed 's|\\\?|\?|' \
 > $DEPLOYMENT_DIR/.env.yml

VIRTUAL_HOST_BASED_WEB_SERVICE_NAME=$(servicename "web${APPVHOST}${COMMITSHA}")

cat stack/docker-compose-production.docker-cloud.yml \
 | sed 's|%COMMITSHA%|'$COMMITSHA'|' \
 | sed 's|%APPVHOST%|'$APPVHOST'|' \
 | sed 's|%DEPLOY_STABILITY_TAG%|'$DEPLOY_STABILITY_TAG'|' \
 | sed 's|%DOCKERCLOUD_USER%|'$DOCKERCLOUD_USER'|' \
 | sed 's|%REPO%|'$REPO'|' \
 | sed 's|%VIRTUAL_HOST%|'"$(sedescape "$VIRTUAL_HOST")"'|' \
 | sed 's|%VIRTUAL_HOST_BASED_WEB_SERVICE_NAME%|'$VIRTUAL_HOST_BASED_WEB_SERVICE_NAME'|' \
 > $DEPLOYMENT_DIR/docker-compose-production.docker-cloud.yml

sed -e '/ENVIRONMENT_YAML/ {' -e 'r '"$DEPLOYMENT_DIR/.env.yml" -e 'd' -e '}' -i '' $DEPLOYMENT_DIR/docker-compose-production.docker-cloud.yml

# prepare new db

if [ "$DATABASE_HOST" == "" ]; then
    $script_path/../util/prepare-new-db.sh $APPVHOST
fi

echo
echo 'Config is prepared for '$APPVHOST'.'
echo
echo "To deploy to docker-cloud (using the currently set Docker Cloud user 'DOCKERCLOUD_USER=$DOCKERCLOUD_USER'):"
echo
echo "  vendor/neam/dna-project-base-cloud-deployment/deploy/to-docker-cloud.sh $DEPLOYMENT_DIR"
echo
echo '(Make sure you have built and pushed the docker images docker-cloud registry before deploying)'
echo
