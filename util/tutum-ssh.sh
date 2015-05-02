#!/usr/bin/env bash

if [ "$1" == "" ]; then

  # choose the latest stack
  export STACK_NAME=$(ls $DEPLOYMENTS_ROOT/ | grep \\-$APPVHOST\\-$COMMITSHA | tail -n 1)
  if [ "$STACK_NAME" == "" ]; then
    echo "No stack found at $DEPLOYMENTS_ROOT/<date>-$APPVHOST-$COMMITSHA/"
    exit 1
  fi

else
  export STACK_NAME=$1
fi

export DEPLOYMENT_DIR="$DEPLOYMENTS_ROOT/$STACK_NAME"
cd "$DEPLOYMENT_DIR"

STACK_ID=$(cat .tutum-stack-id)
tutum stack inspect $STACK_ID > .tutum-stack.json
WORKER_CONTAINER_ID=$(cat .tutum-stack.json | jq '.services | map(select(.name == "worker"))' | jq -r '.[0].containers[0]' | awk -F  "/" '{print $5}')
tutum container inspect $WORKER_CONTAINER_ID > .tutum-worker-container.json
SSH_PORT=$(cat .tutum-worker-container.json | jq '.container_ports[0].outer_port')
SSH_FQDN=$(cat .tutum-worker-container.json | jq -r '.link_variables.WORKER_ENV_TUTUM_NODE_FQDN')

echo "Init and connect:"
echo "export SSH_PORT=$SSH_PORT"
echo "export SSH_FQDN=$SSH_FQDN"
echo 'scp -r -P $SSH_PORT '$DEPLOYMENT_DIR'/.env root@$SSH_FQDN:/.env'
echo 'scp -r -P $SSH_PORT .files/'$DATA'/media/* root@$SSH_FQDN:/files/'$DATA'/media/'
echo
echo "Use local ssh keys:"
echo "echo 'Host $SSH_FQDN' >> ~/.ssh/config"
echo "echo '	ForwardAgent yes' >> ~/.ssh/config"
echo
echo "Connect:"
echo 'ssh -p $SSH_PORT root@$SSH_FQDN'
echo
echo "When connected:"
echo "source /.env"
echo
echo "# File permissions"
echo "chown -R \$WEB_SERVER_POSIX_USER:\$WEB_SERVER_POSIX_GROUP /files"
echo
echo "# Be able to run commands like reset-db etc"
echo "git clone --recursive \$PROJECT_GIT_REPO /app"
echo "cd /app"
echo "cp /.env .env"
echo "git checkout "$COMMITSHA
echo "PREFER=dist stack/src/install-deps.sh"
echo "PREFER=source stack/src/install-deps.sh"
echo
echo "Then run commands"

exit 0