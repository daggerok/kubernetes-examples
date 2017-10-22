#!/usr/bin/env bash
#set -x

docker-compose -f ./docker-swarm/old/src/application-services-stack.yml down -v
docker-compose -f ./docker-swarm/old/src/backing-services-stack.yml down -v

docker swarm leave --force
docker system prune -af --volumes
