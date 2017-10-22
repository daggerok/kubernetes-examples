#!/usr/bin/env bash
#set -x

docker-compose -f ./docker-swarm/docker-compose.yml down -v
docker swarm leave --force
docker system prune -af --volumes
