#!/bin/bash

docker run --rm -it -v ./$1:/etc/gitlab-runner \
docker-group.repo.svc.internal/gitlab-org/gitlab-runner:alpine-v15.2.2 register --name "$1" --executor "docker" --docker-image "docker-group.repo.svc.internal/ubuntu:jammy-utils-latest" \
 --url "http://192.168.201.83:8088/" --registration-token "GR1348941N" --tag-list "tn,toc,zoo" \
 --non-interactive
