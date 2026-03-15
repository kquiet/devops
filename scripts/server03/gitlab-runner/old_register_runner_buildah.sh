#!/bin/bash

docker run --rm -it -v ./$1:/etc/gitlab-runner \
docker-group.repo.svc.internal/gitlab-org/gitlab-runner:alpine-v15.2.2 register --name "$1" --executor "docker" --docker-image "quay.io/buildah/stable:v1.31.0" \
 --url "http://192.168.201.83:8088/" --registration-token "XueB6oXY8R" --tag-list "tw buildah" \
 --docker-devices "/dev/fuse" --docker-security-opt "seccomp:unconfined" --docker-security-opt "apparmor:unconfined" \
 --non-interactive
