[[_TOC_]]

# PyPI Repository使用說明
以下連結若欲使用網域名稱的方式連線，請先[新增DNS](/docs/dns/setup.md)及[匯入受信任的根憑證授權單位(trusted root certificate authorities)](/docs/certificate/setup-root-ca.md)。

## 安裝套件
| 以ip位置連線的網址 | 以網域名稱連線的網址 |
| ----- | ----- |
| http://192.168.23.123:8081/repository/pypi-group/simple | https://repo.svc.internal/repository/pypi-group/simple |

1. 切換至python虛擬環境下
2. 安裝套件XXX
   - 使用pip: ```pip install --index-url http://192.168.23.123:8081/repository/pypi-group/simple --trusted-host 192.168.23.123 XXXX```。亦可將下列設定
        ```ini
        [global]
        index-url = http://192.168.23.123:8081/repository/pypi-group/simple
        trusted-host = 192.168.23.123
        # or use below two lines by using host name
        # index-url = https://repo.svc.internal/repository/pypi-group/simple
        # cert = /path/to/certificate.crt
        ```
        加到```~/.pip/pip.conf```(for linux)或```%APPDATA%\pip\pip.ini```(for windows)，其中的`/path/to/certificate.crt`需置換為實際的根憑證存放路徑(使用host name時才需要)。
   - 使用poetry: 在pyproject.toml內加入
        ```toml
        [[tool.poetry.source]]
        name = "pypi-group"
        url = "http://192.168.23.123:8081/repository/pypi-group/simple"
        # or use below line by using host name
        # url = "https://repo.svc.internal/repository/pypi-group/simple"
        priority = "primary"
        ```
        接著執行```poetry add XXX```即可。若欲使用host name的方式，可執行`poetry config certificates.pypi-group.cert /path/to/certificate.crt`設定憑證路徑；或是在`~/.config/pypoetry/auth.toml`(for linux)或`%APPDATA%\pypoetry\auth.toml`加入以下內容：
        ```toml
        [certificates.pypi-group]
        cert = "/path/to/certificate.crt"
        ```
3. 安裝所有套件
   - pip: 執行```pip install -r requirements.txt```
   - poetry: 執行```poetry install```

## 發佈套件
| 以ip位置連線的網址 | 以網域名稱連線的網址 |
| ----- | ----- |
| http://192.168.23.123:8081/repository/pypi-internal/simple | https://repo.svc.internal/repository/pypi-internal/simple |

1. 以下僅提供poetry的發佈方法
2. 切換至專案目錄，在pyproject.toml內加入發佈目的repository的資訊
    ```toml
    [[tool.poetry.source]]
    name = "pypi-internal"
    url = "http://192.168.23.123:8081/repository/pypi-internal"
    priority = "explicit"
    ```
3. 設定發佈套件至目的repository(pypi-internal)時，所使用的帳號、密碼。有以下兩種方式：
    1. 設定發佈帳號、密碼至環境變數
         - Linux請在bash環境執行以下指令
               ```
               export POETRY_HTTP_BASIC_PYPI_INTERNAL_USERNAME="username"
               export POETRY_HTTP_BASIC_PYPI_INTERNAL_PASSWORD="password"
               ```
         - Windows請在powershell環境執行以下指令
               ```
               $env:POETRY_HTTP_BASIC_PYPI_INTERNAL_USERNAME = "username"
               $env:POETRY_HTTP_BASIC_PYPI_INTERNAL_PASSWORD = "password"
               ```
    2. 設定發佈帳號、密碼至poetry設定檔。執行```poetry config http-basic.pypi-internal <username>```，此時會要求您輸入密碼，請輸入。完成後會保存帳號及密碼供未來發佈之用。
       - 帳號存放處：~/.config/pypoetry/auth.toml(Linux); %APPDATA%\pypoetry(Windows)
       - 密碼存放處：GNOME Keyring or SecretService(Linux); Windows Credential Manager(Windows)。
       - (Optional)：在執行```poetry config http-basic.pypi-internal <username>```，先執行```poetry config keyring.enabled false```，可改為將密碼以明碼方式存放至與帳號相同存放處
4. 接著執行```poetry publish --build -r pypi-internal```即可發佈

## 參考連結
- [pip設定](https://pip.pypa.io/en/stable/topics/configuration/)
- [pip如何支援https憑證](https://pip.pypa.io/en/stable/topics/https-certificates/)
- [poetry設定](https://python-poetry.org/docs/configuration/)
- [poetry repository設定](https://python-poetry.org/docs/repositories/)