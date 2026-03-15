#!/bin/bash
helm repo add argo https://argoproj.github.io/argo-helm --force-update

kubectl apply --server-side -k "https://github.com/argoproj/argo-cd/manifests/crds?ref=v3.3.2"

helm upgrade --install argocd argo/argo-cd \
  --namespace argocd --create-namespace \
  --version 9.4.9 \
  -f values.yaml

# afer upgrade, manually modify: 1. configmap 'argocd-cm' (remove Endpoints&EndpointSlice from resource.exclusions)

#add below setting using argocd
## 1. add repo:
##    argocd repo add ssh://git@192.168.201.83:8089/zoo/devops.git --ssh-private-key-path ~/.ssh/id_rsa_devops_gitlab --insecure-ignore-host-key
## 2. add cluster:
##    kubectl config get-contexts -o name
##    argocd cluster add xxxx
## 3. add projects:
##    argocd proj create devops --allow-cluster-resource=*/* --src=* --dest=*,* --source-namespaces=*
##    argocd proj create playground --allow-cluster-resource=*/PersistentVolume --src=* --dest=*,playground --dest=*,test* --source-namespaces=playground,test*
##    argocd proj role create playground admin --description "admin role"
##    argocd proj role add-policy playground admin -o "*" -a "*" -p allow
##    argocd proj role add-group playground admin zoo
## 4. update account password:
##    argocd account update-password --account zoo