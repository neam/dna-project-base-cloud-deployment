#!/usr/bin/env bash
#set -x

# fail on any error
set -o errexit

# debug
#set -x

export DATA=%DATA%
export COMMITSHA=""
export BRANCH_TO_DEPLOY=""
source deploy/prepare.sh

# Usage: deploy.sh <stack-deployment-directory>

DEPLOYMENT_DIR="$1"
STACK_NAME="$(basename $DEPLOYMENT_DIR)"
STACK_UUID=$(cat $DEPLOYMENT_DIR/.docker-cloud-stack-id)

echo "Starting a remote shell in docker-cloud for a specific stack (accessing Docker Cloud via user 'DOCKERCLOUD_USER=$DOCKERCLOUD_USER')"

echo
echo "* Fetching current information about the stack, identified by $STACK_UUID"
echo

docker run -it -e DOCKERCLOUD_USER=$DOCKERCLOUD_USER -e DOCKERCLOUD_PASS=$DOCKERCLOUD_PASS -v "$(pwd)/$DEPLOYMENT_DIR:/deployment-dir" dockercloud/cli service ps --stack=$STACK_UUID \
 | tee "$DEPLOYMENT_DIR/.docker-cloud-stack-service-ps.out"

WORKER_SERVICE_ID=$(cat "$DEPLOYMENT_DIR/.docker-cloud-stack-service-ps.out" | grep 'phpfiles' | awk '{ print $2 }')

echo
echo "* Fetching current information about the worker service, identified by $WORKER_SERVICE_ID"
echo

docker run -it -e DOCKERCLOUD_USER=$DOCKERCLOUD_USER -e DOCKERCLOUD_PASS=$DOCKERCLOUD_PASS -v "$(pwd)/$DEPLOYMENT_DIR:/deployment-dir" dockercloud/cli container ps --service=$WORKER_SERVICE_ID \
 | tee "$DEPLOYMENT_DIR/.docker-cloud-stack-worker-service-container-ps.out"

WORKER_CONTAINER_ID=$(cat "$DEPLOYMENT_DIR/.docker-cloud-stack-worker-service-container-ps.out" | grep 'phpfiles-1' | awk '{ print $2 }')

echo
echo "* Starting a remote shell in the worker service's first container, identified by $WORKER_CONTAINER_ID"
echo

docker run -it -e DOCKERCLOUD_USER=$DOCKERCLOUD_USER -e DOCKERCLOUD_PASS=$DOCKERCLOUD_PASS -v "$(pwd)/$DEPLOYMENT_DIR:/deployment-dir" dockercloud/cli container exec $WORKER_CONTAINER_ID \
  /bin/bash

exit 0
