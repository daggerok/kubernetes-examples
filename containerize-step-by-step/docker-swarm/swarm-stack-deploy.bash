#!/usr/bin/env bash
set -x

# functions declaration begin
function FUNCTION_STATUS_IS_NOT_OK() {
  if ( [ "$1." == "." ] \
      || [ "$2." == "." ] \
      || [ "$3." == "." ] )
    then
      echo "function requires 3 arguments"
      exit -1
  fi

  SERVICE_NAME="$1"
  SCALE_TO="$2"
  STACK_NAME="$3"

  if [ "$SCALE_TO/$SCALE_TO." != "$(docker stack services --filter name=${SERVICE_NAME} --format='{{.Replicas}}' ${STACK_NAME})." ]; then
    return 0 # true
  else
    return 1 # false
  fi
}

function FUNCTION_WAIT_FOR_SERVICE() {
  SERVICE_ID="$1"
  AMOUNT="$2"
  STACK_NAME="$3"
  echo "waiting for $SERVICE_ID bootstrap..."

  SERVICE_NAME="${STACK_NAME}_$SERVICE_ID"
  while $(FUNCTION_STATUS_IS_NOT_OK ${SERVICE_NAME} ${AMOUNT} ${STACK_NAME}); do
    sleep 1
  done
  return 0
}

function FUNCTION_SCALE_SERVICE() {
  SERVICE_ID="$1"
  SCALE_TO="$2"
  STACK_NAME="$3"

  echo "scale service $SERVICE_ID to $SCALE_TO"

  SERVICE_NAME="${STACK_NAME}_$SERVICE_ID"
  while $(FUNCTION_STATUS_IS_NOT_OK ${SERVICE_NAME} ${SCALE_TO} ${STACK_NAME}); do
    docker service scale --detach=false ${SERVICE_NAME}=${SCALE_TO}
  done

  docker stack services --filter name=${SERVICE_NAME} --format="{{.Name}} {{.Replicas}}" ${STACK_NAME}
  return 0
}

# deploy stack to docker swarm cluster
STACK_NAME="containerize-step-by-step"

echo "initialize docker swarm cluster"
docker swarm init > /dev/null #2>&1

echo "initialize registry"
docker service create --detach=false --name registry --publish 5000:5000 registry:2 > /dev/null #2>&1

echo "build images"
docker-compose -f ./docker-swarm/docker-compose.yml build --force-rm --no-cache --pull > /dev/null #2>&1

echo "push images to local registry"
docker-compose -f ./docker-swarm/docker-compose.yml push > /dev/null #2>&1

echo "deploy stack"
docker stack deploy -c ./docker-swarm/docker-compose.yml ${STACK_NAME} > /dev/null #2>&1

echo "bootstrap services in order..."

# backing
LIST_OF_GLOBAL_SERVICES_IN_ORDER="
redis-healthcheck \
"

# application
LIST_OF_REPLICATED_SERVICES_IN_ORDER=" \
redis-commander-healthcheck \
web-app-healthcheck \
"

echo "shutdown unordered services"
for SERVICE_ID in ${LIST_OF_REPLICATED_SERVICES_IN_ORDER}; do
  SCALE_TO=0

  FUNCTION_SCALE_SERVICE ${SERVICE_ID} ${SCALE_TO} ${STACK_NAME}
  FUNCTION_WAIT_FOR_SERVICE ${SERVICE_ID} ${SCALE_TO} ${STACK_NAME}
done

echo "wait for global services"
for SERVICE_ID in ${LIST_OF_GLOBAL_SERVICES_IN_ORDER}; do
  AMOUNT=1

  FUNCTION_WAIT_FOR_SERVICE ${SERVICE_ID} ${AMOUNT} ${STACK_NAME}
done

echo "startup application services in order"
for SERVICE_ID in ${LIST_OF_REPLICATED_SERVICES_IN_ORDER}; do
  SCALE_TO=1

  FUNCTION_SCALE_SERVICE ${SERVICE_ID} ${SCALE_TO} ${STACK_NAME}
done

echo "application is ready"
docker stack services ${STACK_NAME}
