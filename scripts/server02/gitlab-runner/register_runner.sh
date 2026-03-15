#!/bin/bash

docker run --rm -it -v ./$1:/etc/gitlab-runner \
docker-group.repo.svc.internal/gitlab/gitlab-runner:alpine3.21-v18.5.0 register --name "$1" --executor "docker" \
    --docker-image "docker-group.repo.svc.internal/ubuntu:jammy-utils-latest" \
    --docker-helper-image "docker-group.repo.svc.internal/gitlab/gitlab-runner-helper:alpine3.21-x86_64-v18.7.0" \
    --url "http://192.168.201.83:8088/" --token "$2" --non-interactive --output-limit 10240 \
    --docker-security-opt "seccomp:unconfined" --docker-security-opt "apparmor:unconfined" \
    --docker-volumes "/opt/docker_volumes/gitlab-runner-cache/$1:/cache" \
    --docker-pull-policy "always" --docker-pull-policy "if-not-present"
