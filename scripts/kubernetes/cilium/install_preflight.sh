#!/bin/bash

helm repo add cilium https://helm.cilium.io

helm install cilium-preflight cilium/cilium --version 1.18.5 --namespace kube-system \
  --set preflight.enabled=true \
  --set agent=false \
  --set operator.enabled=false \
  --set k8sServiceHost=127.0.0.1 \
  --set k8sServicePort=6443

