[[_TOC_]]

# Apt Repository使用說明
以下連結若欲使用網域名稱的方式連線，請先[新增DNS](/docs/dns/setup.md)及[匯入受信任的根憑證授權單位(trusted root certificate authorities)](/docs/certificate/setup-root-ca.md)。

## 安裝套件
| 以ip位置連線的網址 | 以網域名稱連線的網址 |
| ----- | ----- |
| http://192.168.23.123:8081/repository/apt-proxy/ | https://repo.svc.internal/repository/apt-proxy/ |

1. 修改 `/etc/apt/source.list`的repo設定如下：
    ```
    deb http://192.168.23.123:8081/repository/apt-proxy/ jammy main restricted universe multiverse

    deb http://192.168.23.123:8081/repository/apt-proxy/ jammy-security main restricted universe multiverse
    ```
2. 安裝套件XXXX： ```apt-get install XXXX```