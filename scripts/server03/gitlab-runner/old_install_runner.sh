#~/bin/bash

docker run -d --name $1 \
    --restart=always \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v ./$1:/etc/gitlab-runner \
    gitlab/gitlab-runner:ubuntu-v16.3.1
