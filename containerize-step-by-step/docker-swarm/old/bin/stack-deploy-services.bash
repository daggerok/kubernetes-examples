#!/usr/bin/env bash
#set -x
prefix="containerize-step-by-step"

# init cluster
docker swarm init

# setup registry
docker service create --detach=false --name registry --publish 5000:5000 registry:2

# bootstrap backing services
docker-compose -f ./docker-swarm/old/src/backing-services-stack.yml build --force-rm --no-cache --pull
docker-compose -f ./docker-swarm/old/src/backing-services-stack.yml push
docker stack deploy -c ./docker-swarm/old/src/backing-services-stack.yml ${prefix}

for suffix in visualizer redis; do
  service_name="${prefix}_$suffix"
  echo "waiting for $service_name bootstrap..."
  while [ "$(docker stack services --filter name=${service_name} --format='{{.Replicas}}' ${prefix})." != "1/1." ]; do
    sleep 1
  done
  docker stack services --filter name="$service_name" --format="{{.Name}} {{.Replicas}}" ${prefix}
done

# bootstrap application services
docker-compose -f ./docker-swarm/old/src/application-services-stack.yml build --force-rm --no-cache --pull
docker-compose -f ./docker-swarm/old/src/application-services-stack.yml push
docker stack deploy --compose-file ./docker-swarm/old/src/application-services-stack.yml ${prefix}

source_iterator="redis-commander-healthcheck web-app-healthcheck"

for suffix in ${source_iterator}; do
  service_name="${prefix}_$suffix"
  docker service scale --detach=false "$service_name"="0"
done

for suffix in ${source_iterator}; do
  service_name="${prefix}_$suffix"
  echo "waiting for $service_name bootstrap..."
  while [ "$(docker stack services --filter name=${service_name} --format='{{.Replicas}}' ${prefix})." != "1/1." ]; do
    docker service scale --detach=false "$service_name"="1"
    sleep 1
  done
  docker stack services --filter name="$service_name" --format="{{.Name}} {{.Replicas}}" ${prefix}
done

docker stack services containerize-step-by-step
