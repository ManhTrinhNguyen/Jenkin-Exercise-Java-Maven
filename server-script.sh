#!/usr/bin/env bash 
export Image=$1

docker-compose -f docker-compose.yaml up -detach 
echo "success"