#!/usr/bin/env bash
$(aws ecr get-login --no-include-email --region eu-west-1)
docker build -t hello_world .
docker tag hello_world:latest 179431106284.dkr.ecr.eu-west-1.amazonaws.com/hello_world:latest
docker push 179431106284.dkr.ecr.eu-west-1.amazonaws.com/hello_world:latest