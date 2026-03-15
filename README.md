# DevOps環境資訊
此頁面描述各系統的連結及使用方式。

## 1. DNS
### 簡介
自建DNS可以為單位內自建自管的應用系統提供命名解析。當系統IP地址異動時，只需在此DNS中進行調整，避免每個人都必須手動修改設定。
### DNS列表
| IP |
|------|
| 192.168.201.83 |

可參考[這裡](docs//dns/setup.md)以新增DNS到目前連入Office所使用的網路連線中。

## 2. Gitlab CE(Community Edition)
### 簡介
團隊用來管理軟體開發項目的平台。它提供了版本控制、協作開發、CI/CD 自動化流程、問題追蹤和合併請求管理等功能。透過自建 GitLab，團隊可以完全控制程式碼庫和開發環境，並保障內部專案的安全性和隱私，避免依賴第三方雲端服務。

### 首頁連結
請以ldap帳密登入瀏覽： http://192.168.201.83:8088/ or https://gitlab.svc.internal/ 。

## 3. 套件儲存庫(Repository)
### 簡介
作為集中管理的套件儲存庫，預計會啟用npm、Docker、PyPI、Helm 和 apt等五種類型，方便單位內的成員共享、快速抓取套件資源。

註1: 以下連結若欲使用網域名稱的方式連線，請先[新增DNS](/docs/dns/setup.md)及[匯入受信任的根憑證授權單位(trusted root certificate authorities)](/docs/certificate/setup-root-ca.md)。

### 首頁連結
請以ldap帳密登入瀏覽： http://192.168.23.123:8081/ or https://repo.svc.internal/ 。

### NPM Repository
| 名稱 | 描述 |
|------|------|
| npm-proxy | 作用是代理外部npm儲存庫(`https://registry.npmjs.org`)，加速訪問並減少對外部repo的依賴。下載套件時不應使用此repo，而是使用npm-group這個repo。保存在此repo的套件若30天內沒有任何下載，會自動被清空。|
| npm-internal | 存放團隊開發的私有npm repo，僅供內部套件發佈使用。npm publish時請使用此repo。保存在此repo的套件會被永久保留，不會被自動清空。 |
| npm-group | 將多個npm repo（包括npm-proxy和npm-internal）聚合為單一入口。npm install時請使用此repo。 |

[NPM Repository使用說明](/docs/nexus-repository/npm-repo.md)

### PyPI Repository
| 名稱 | 描述 |
|------|------|
| pypi-proxy | 作用是代理外部pypi儲存庫(`https://pypi.org/`)，加速訪問並減少對外部repo的依賴。下載套件時不應使用此repo，而是使用pypi-group這個repo。保存在此repo的套件若30天內沒有任何下載，會自動被清空。|
| pypi-internal | 存放團隊開發的私有pypi repo，僅供內部套件發佈使用。poetry publish時請使用此repo。保存在此repo的套件會被永久保留，不會被自動清空。 |
| pypi-group | 將多個pypi repo（包括pypi-proxy和pypi-internal）聚合為單一入口。poetry install時請使用此repo。 |

[PyPI Repository使用說明](/docs/nexus-repository/pypi-repo.md)

### Docker Repository
| 名稱 | 描述 |
|------|------|
| docker-proxy | 作用是代理外部docker儲存庫(`https://registry-1.docker.io`, `https://quay.io`, `https://gcr.io`, `https://registry.gitlab.com`)，加速訪問並減少對外部repo的依賴。下載套件時不應使用此repo，而是使用docker-group這個repo。保存在此repo的套件若30天內沒有任何下載，會自動被清空。|
| docker-internal | 存放團隊開發的私有docker repo，僅供內部套件發佈使用。docker push時請使用此repo。保存在此repo的套件會被永久保留，不會被自動清空。 |
| docker-group | 將多個docker repo（包括docker-proxy和docker-internal）聚合為單一入口。docker pull時請使用此repo。 |

[Docker Repository使用說明](/docs/nexus-repository/docker-repo.md)

### Apt Repository
| 名稱 | 描述 |
|------|------|
| apt-proxy | 作用是代理外部apt儲存庫(`http://tw.archive.ubuntu.com/ubuntu/`)，加速訪問並減少對外部repo的依賴。下載套件時請直接使用此repo。保存在此repo的套件若30天內沒有任何下載，會自動被清空。|

[Apt Repository使用說明](/docs/nexus-repository/apt-repo.md)

## 4. Playground環境
### 簡介
主要用途包括：
 - POC驗證：快速測試與驗證新技術或解決方案的可行性。
 - 技術實驗：探索新工具、框架及技術的實驗場所。
 - 共享學習：構建示範案例，與其他分享成果、互相學習。

此環境為部門成員共享，CPU/Memory/磁碟資源有限，請避免長時(超過1分鐘)獨占大量(超過總量50%)系統資源。

# 其它資訊
## 系統管理
 - 請參考[此處](administration.md)的說明。
## python開發環境相關
 - [poetry安裝說明](/docs/python/install-poetry.md)
## ssh連線相關
 - [port forward使用說明](/docs/ssh/port-forward.md)
