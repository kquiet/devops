#!/bin/bash

# create pv, pvc, secret first
kubectl apply -f ./init-resources.yaml

# install mariadb
helm install mariadb oci://registry-1.docker.io/bitnamicharts/mariadb --version 19.0.7 --namespace devops --create-namespace --values ./values.yaml
