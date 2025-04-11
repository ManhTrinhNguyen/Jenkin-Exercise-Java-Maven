#!/usr/bin/env bash 
export IMAGE=$1

USER=$2
PWD=$3

docker login -u ${USER} -p ${PWD}

docker-compose -f docker-compose.yaml up -d
echo "success"