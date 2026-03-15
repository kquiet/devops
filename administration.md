[[_TOC_]]

# DNS Server
1. 系統版本：CoreDNS v1.14.2
2. 概要描述：負責將DNS名稱解析成各系統所在主機的IP，確保在主機ip異動時仍可用DNS名稱互相通訊。
3. 機器位置：server01(192.168.201.83)
4. 安裝方式：docker container. [docker-compose.yaml](/scripts/server01/coredns/docker-compose.yaml)
5. 備份方式：不必要，因為[core file](/scripts/server01/coredns/Corefile)及[zones file](scripts/server01/coredns/zones/svc.internal.db)皆保存在gitlab。
6. License：[Apache License 2.0](https://github.com/coredns/coredns/blob/v1.14.2/LICENSE)
7. 服務位置：192.168.201.83:53

# Gitlab
1. 系統版本：Gitlab CE 18.7.0
2. 概要描述：存放團隊專案所開發的原始碼，並提供自定義pipeline以減少人工手動操作、提升軟體發展效率與品質。
3. 機器位置：server01(192.168.201.83)
4. 安裝方式：docker container. [docker-compose.yaml](/scripts/server01/gitlab/docker-compose.yml)
5. 備份方式：ansible awx schedule.
    - 每日凌晨3:00執行備份
    - 僅保留最近3次的備份
    - 備份至//someserver01.oa.internal/somepath$/devops_backup/gitlab
6. License：[MIT License](https://gitlab.com/rluna-gitlab/gitlab-ce/-/blob/v18.7.0/LICENSE)
7. 服務網址：http://192.168.201.83:8088/ (https://gitlab.svc.internal/)
8. 備註：已整合ldap帳號登入

# Gitlab Runner
1. 系統版本：Gitlab Runner 18.7.0
2. 概要描述：運行Gitlab各專案所定義的pipeline。
3. 機器位置：server03(192.168.23.123)內的VM "Ubuntu"、server02(192.168.23.168)、server01(192.168.201.83)的k3s cluster。
4. 安裝方式：docker container. [docker-compose.yaml](/scripts/server03/gitlab-runner/docker-compose.yaml)
5. 備份方式：不需要，因為服務本身只運行gitlab ci job，而不提供任何儲存服務
6. License：[MIT License](https://gitlab.com/gitlab-org/gitlab-runner/-/blob/v18.7.0/LICENSE)

# Nexus Repository
1. 系統版本：Nexus Repository OSS 3.76.1
2. 概要描述：套件儲存及管理工具，支援多種常見的套件格式，例如：npm, python, docker, apt等。也被無法對外連線取得套件的主機或系統作為套件proxy使用。
3. 機器位置：server03(192.168.23.123)內的VM "Ubuntu" - 此VM是以NAT網路透過server03主機連接至Office網路，因此若需要從Office環境連線至VM內的服務，需在server03主機設定port forward轉發。
4. 安裝方式：docker container. [docker-compose.yaml](/scripts/server03/nexus-repository/docker-compose.yaml)
5. 備份方式：ansible awx schedule.
    - 每日凌晨0:00執行備份
    - 僅保留最近2次的備份
    - 備份至//someserver01.oa.internal/somepath$/devops_backup/nexus-repository
6. License：[Eclipse Publish License 1.0](https://github.com/sonatype/nexus-public/blob/release-3.76.1-01/LICENSE.txt)
7. 服務網址：http://192.168.23.123:8081/ (https://repo.svc.internal/)
8. 備註：已整合ldap帳號登入

# MySQL
1. 系統版本：MySQL 8.0.32
2. 概要描述：關聯式資料庫，供內網系統使用。
3. 機器位置：server01(192.168.201.83)
4. 安裝方式：docker container. [docker-compose.yaml](/scripts/server01/mysql/docker-compose.yml)
5. 備份方式：ansible awx schedule.
    - 每日02:00執行備份
    - 僅保留最近7次的備份
    - 備份至//someserver01.oa.internal/somepath$/devops_backup/mysql
6. License：[GPL License version 2](https://github.com/mysql/mysql-server/blob/mysql-8.0.32/LICENSE)
7. 服務位置：192.168.201.83:3306

# MariaDB
1. 系統版本：MariaDB 11.8.5
2. 概要描述：關聯式資料庫，供內網系統使用。
3. 機器位置：server01(192.168.201.83)
4. 安裝方式：docker container. [docker-compose.yaml](/scripts/server01/mariadb/docker-compose.yml)
5. 備份方式：ansible awx schedule.
    - 每日凌晨1:10執行備份
    - 僅保留最近7次的備份
    - 備份至//someserver01.oa.internal/somepath$/devops_backup/mariadb
6. License：[GPL License version 2](https://github.com/MariaDB/server/blob/mariadb-11.8.5/COPYING)
7. 服務位置：192.168.201.83:13306

# WordPress
1. 系統版本：WordPress 6.6.2-fpm (combined with nginx 1.27.2)
2. 概要描述：內容管理系統，用於存放、展示、管理知識文件。
3. 機器位置：server01(192.168.201.83)
4. 安裝方式：docker container. [docker-compose.yaml](/scripts/server01/wordpress/zoo/docker-compose.yml)
5. 備份方式：ansible awx schedule.
    - 每日凌晨1:40執行備份
    - 僅保留最近7次的備份
    - 備份至//someserver01.oa.internal/somepath$/devops_backup/wordpress
6. License：
    - nginx: [2-clause BSD-like License](https://nginx.org/LICENSE)
    - wordpress: [GPL License version 2](https://tw.wordpress.org/about/license/)
    - wordpress plugin - WP Editor.md v10.2.1: [GPL License version 3](https://plugins.trac.wordpress.org/browser/wp-editormd/tags/10.2.1/LICENSE)
    - wordpress plugin - Active Directory Integration for Intranet Sites v5.1.7: [MIT License](https://plugins.trac.wordpress.org/browser/ldap-login-for-intranet-sites/tags/5.1.7/readme.txt)
    - wordpress plugin - Shortcoder v6.4: [GPL License version 2](https://plugins.trac.wordpress.org/browser/shortcoder/tags/6.4/readme.txt)
    - wordpress plugin - Co-Authors Plus v3.6.3: [GPL License version 2](https://plugins.svn.wordpress.org/co-authors-plus/tags/3.6.3/LICENSE)
7. 服務網址：http://192.168.201.83:8061/

# Kroki
1. 系統版本：Kroki v0.30.1
2. 概要描述：支援使用簡單的文字描述語言來定義圖表結構的工具。目前主要提供給Gitlab顯示圖表使用。
3. 機器位置：server01(192.168.201.83)
4. 安裝方式：docker container. [docker-compose.yaml](/scripts/server01/kroki/docker-compose.yml)
5. 備份方式：不必要，因為系統本身不保存任何狀態資料。
6. License：[MIT License](https://github.com/yuzutech/kroki/blob/v0.30.1/LICENSE)
7. 服務網址：http://192.168.201.83:8191/ (https://kroki.svc.internal/)

# statping
1. 系統版本：statping v0.90.74
2. 概要描述：自動偵測服務運行狀況，並生成視覺化狀態圖表。
3. 機器位置：server03(192.168.23.123)內的VM "Ubuntu" - 此VM是以NAT網路透過server03主機連接至Office網路，因此若需要從Office環境連線至VM內的服務，需在server03主機設定port forward轉發。
4. 安裝方式：docker container. [docker-compose.yaml](/scripts/server03/statping/docker-compose.yml)
5. 備份方式：尚無
6. License：[GPL License version 3](https://github.com/statping/statping/blob/v0.90.74/LICENSE)
7. 服務網址：http://192.168.23.123:8080/

# Kubernetes Cluster
## Server Node(Control Plane)
1. 系統版本：k3s v1.34.5+k3s1
2. 概要描述：輕量級的Kubernetes發行版，用於統一化運行各容器系統的平台。
3. 機器位置：目前僅server01(192.168.201.83)
4. 安裝方式：下載k3s執行檔以root帳號安裝。[script](scripts/server01/k3s/install_k3s.sh)
5. 備份方式：ansible awx schedule.
    - 每日凌晨1:00執行備份
    - 僅保留最近2次的備份
    - 備份至//someserver01.oa.internal/somepath$/devops_backup/k3s
6. License：[Apache License 2.0](https://github.com/k3s-io/k3s/blob/v1.34.5%2Bk3s1/LICENSE)

## Agent Node(Worker)
暫無

## Container Network Interface(CNI, Cilium)
1. 系統版本：cilium v1.18.5
2. 概要描述：提供k3s實現基礎及進階網路通訊的基礎元件。
3. 安裝方式：helm chart。 [script](/scripts/kubernetes/cilium/install.sh)
4. 備份方式：不必要，因為resource設定都保存在gitlab。
5. License：[Apache License 2.0](https://github.com/cilium/cilium/blob/v1.18.5/LICENSE)
6. 備註：暫不更新為v1.19.1。[Issue](https://github.com/cilium/cilium/issues/44430)

## 部署管理(ArgoCD)
1. 系統版本：argocd v3.3.2
2. 概要描述：基於kubernetes的宣告式自動化部署工具。用於統一化部署各容器系統。
3. 安裝方式：helm chart。 [script](/scripts/kubernetes/argocd/install_argocd.sh)
4. 備份方式：不必要，因為resource設定都保存在gitlab。
5. License：[Apache License 2.0](https://github.com/argoproj/argo-cd/blob/v3.3.2/LICENSE)
6. 服務網址：https://argocd.svc.internal/

## 維運管理(Ansible AWX)
1. 系統版本：Ansible AWX 24.6.1 (through AWX Operator 2.19.1)
2. 概要描述：提供Web視覺化介面的維運統一化平台。目前主要包含了:安裝及配置主機環境、Proxy連線及系統備份等任務及排程。
3. 安裝方式：kustomize by argocd。[manifest](/scripts/kubernetes/apps/devops/root-app/base/app-awx-resources.yaml)
4. 備份方式：因為設定都保存在postgresql，所以是透過備份postgresql的方式進行備份。
5. License：
    - Ansible AWX: [Apache License 2.0](https://github.com/ansible/awx/blob/24.6.1/LICENSE.md)
    - AWX Operator: [Apache License 2.0](https://github.com/ansible/awx-operator/blob/2.19.1/LICENSE)
6. 服務網址：https://awx.svc.internal/
7. 備註：已整合ldap帳號登入

## 憑證管理(cert-manager)
1. 系統版本：cert-manager v1.19.4
2. 概要描述：憑證管理的工具。主要用於自動簽發、更新SSL/TLS憑證，讓各系統可以透過https及DNS名稱進行通訊。
3. 安裝方式：kustomize by argocd。[manifest](/scripts/kubernetes/apps/devops/root-app/base/app-cert-manager-resources.yaml)
4. 備份方式：不必要，因為resource設定都保存在gitlab。
5. License：[Apache License 2.0](https://github.com/cert-manager/cert-manager/blob/v1.19.4/LICENSE)

## 機密管理
### HashiCorp Vault
1. 系統版本：hashicorp vault community edition v1.21.2
2. 概要描述：集中式機密管理工具，用來安全地儲存、存取和管理各種敏感資訊，例如 API 金鑰、密碼、憑證和令牌。用於避免將前述機密存放於主機、Gitlab。
3. 安裝方式：kustomize by argocd。[manifest](/scripts/kubernetes/apps/devops/root-app/base/app-vault-resources.yaml)
4. 備份方式：ansible awx schedule.
    - 每日凌晨1:30執行備份
    - 僅保留最近28次的備份
    - 備份至//someserver01.oa.internal/somepath$/devops_backup/hashicorp_vault
5. License：[Business Source License 1.1](https://github.com/hashicorp/vault/blob/v1.21.2/LICENSE)
6. 服務網址：https://vault.svc.internal/
7. 備註：已整合ldap帳號登入
### HashiCorp Vault Secrets Operator
1. 系統版本：hashicorp vault secrets operator v1.3.0
2. 概要描述：自動從vault中讀取密碼或金鑰，並將其同步為Kubernetes Secret，讓kubernetes內的各系統能在不需管理這些密碼或金鑰的情況下使用它們，用以提高安全性、簡化管理。
3. 安裝方式：kustomize by argocd。[manifest](/scripts/kubernetes/apps/devops/root-app/base/app-vault-resources.yaml)
4. 備份方式：不必要，因為resource設定都保存在gitlab。
5. License：[Business Source License 1.1](https://github.com/hashicorp/vault-secrets-operator/blob/v1.3.0/LICENSE)

## 資料庫
### 資料庫管理(adminer)
1. 系統版本：adminer 5.4.2
2. 概要描述：網頁版本的輕量級資料庫管理工具，用於測試此頁面所提到的資料庫系統。
3. 安裝方式：helm chart
4. 備份方式：不必要，因為resource設定都保存在gitlab。
5. License：[Apache License 2.0](https://github.com/vrana/adminer/blob/v5.4.2/LICENSE)
6. 服務網址：https://adminer.svc.internal/
### Postgresql
1. 系統版本：Postgresql 17.6.0
2. 概要描述：關聯式資料庫，供內網系統使用。
3. 機器位置：server01(192.168.201.83)
4. 安裝方式：kustomize by argocd。[manifest](/scripts/kubernetes/apps/devops/root-app/base/app-postgresql-resources.yaml)
5. 備份方式：ansible awx schedule.
    - 每日凌晨2:30執行備份
    - 僅保留最近7次的備份
    - 備份至//someserver01.oa.internal/somepath$/devops_backup/postgresql
6. License：[The PostgreSQL License](https://www.postgresql.org/about/licence/)
7. 服務位置：192.168.201.83:5432