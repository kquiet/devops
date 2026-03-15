#add below setting using vault
## 1. add admin policies and configure for admin account
vault policy write admin ./admin.hcl
vault auth enable userpass
vault write auth/userpass/users/devops policies=admin password="changeafter"

## 2. add other policies
vault policy write devops ./devops.hcl
vault policy write gitlab ./gitlab.hcl
vault policy write phm ./phm.hcl
vault policy write phm-admin ./phm-admin.hcl

## 3. enable kv secrets engine and provision root ca certificate/key
vault secrets enable -path=kv kv-v2
vault kv put kv/devops/ca/root tls.crt=@zooDeveloperPlatformRootCA.crt tls.key=@zooDeveloperPlatformRootCA.key

## 4. enable kubernetes auth method & add the role of kubernetes auth for VSO(vault secrets operator)
vault auth enable kubernetes
vault write auth/kubernetes/config kubernetes_host=https://kubernetes.default.svc
vault write auth/kubernetes/role/vault-k8s-devops \
    bound_service_account_names=default \
    bound_service_account_namespaces=cert-manager,argocd,gitlab-runner,devops \
    policies=devops \
    audience=vault

## 5. add role for snapshot
vault write auth/kubernetes/role/snapshot \
    bound_service_account_names=vault \
    bound_service_account_namespaces=vault \
    policies=devops \
    audience="https://kubernetes.default.svc.cluster.local" \
    ttl=10m

## 6. enable ldap login
vault auth enable ldap
vault write auth/ldap/config url="ldap://ldap.oa.internal" \
    userattr="sAMAccountName" \
    binddn="${LDAP_USERNAME}" \
    bindpass="${LDAP_PASSWORD}" \
    userdn="dc=oa,dc=internal" \
    userfilter="(&(objectClass=user)({{.UserAttr}}={{.Username}})(|(department=ZOO164800)(department=ZOO164802)(department=ZOO164803)))" \
    groupfilter="(&(objectClass=group)(member={{.UserDN}}))" \
    groupattr="cn" \
    groupdn="dc=oa,dc=internal"

## 7. enable approle login & add role for awx
vault auth enable approle

## 7.1 configure approle for awx
vault write auth/approle/role/awx token_policies="default,devops" token_ttl=1h token_max_ttl=4h
## Get role id
vault read auth/approle/role/awx/role-id
## Create a new secret id and echo on screen(once)
vault write -f auth/approle/role/awx/secret-id

## 7.2 configure approle for gitlab
vault write auth/approle/role/gitlab token_policies="default,gitlab" token_ttl=1h token_max_ttl=4h
vault read auth/approle/role/gitlab/role-id
vault write -f auth/approle/role/gitlab/secret-id

## 7.3 configure approle for phm
vault write auth/approle/role/phm token_policies="default,phm" token_ttl=1h token_max_ttl=4h
vault read auth/approle/role/phm/role-id
vault write -f auth/approle/role/phm/secret-id

## Reference: login through role id and secret id
## vault write auth/approle/login role_id=<YOUR_ROLE_ID> secret_id=<YOUR_SECRET_ID>
## Reference: list secret-id-accessor
## vault list auth/approle/role/<ROLE_NAME>/secret-id
## Reference: revoke all secret-id
## vault write auth/approle/role/<ROLE_NAME>/secret-id-accessor/destroy secret_id_accessor=<ACCESSOR_VALUE>