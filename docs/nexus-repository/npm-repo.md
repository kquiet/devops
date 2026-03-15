[[_TOC_]]

# NPM Repository使用說明
以下連結若欲使用網域名稱的方式連線，請先[新增DNS](/docs/dns/setup.md)及[匯入受信任的根憑證授權單位(trusted root certificate authorities)](/docs/certificate/setup-root-ca.md)。

## 安裝套件
| 以ip位置連線的網址 | 以網域名稱連線的網址 |
| ----- | ----- |
| http://192.168.23.123:8081/repository/npm-group/ | https://repo.svc.internal/repository/npm-group/ |

1. 切換至欲安裝npm套件的目錄下(e.g.: /git/zoo/frontend)
2. 安裝套件： ```npm install --registry http://192.168.23.123:8081/repository/npm-group/```

## 發佈套件
| 以ip位置連線的網址 | 以網域名稱連線的網址 |
| ----- | ----- |
| http://192.168.23.123:8081/repository/npm-internal/ | https://repo.svc.internal/repository/npm-internal/ |

1. 執行 ```npm login --registry http://192.168.23.123:8081/repository/npm-internal/```
2. 輸入AD帳密，登入成功會看到類似文字：```Logged in on http://192.168.23.123:8081/repository/npm-internal/.```
3. 切換至欲發佈的套件目錄下(e.g.: /git/zoo/storybook/ui-lib)
4. 發佈套件： ```npm publish --registry http://192.168.23.123:8081/repository/npm-internal/```

## Q&A 
1. 使用 `npm install/publish`連線到https://repo.svc.internal/repository/npm-xxxxx/ 時發生`unable_to_get_issuer_cert_locally` 的錯誤
    - 原因：npm 無法識別https://repo.svc.internal 所使用的自簽憑證
    - 解決方式:執行`npm config set cafile <根憑證檔案路徑>`，讓npm能夠識別該自簽憑證。根憑證檔案下載方式可參考[這裡](/docs/certificate/setup-root-ca.md)。

## 參考連結
 - [npm config](https://docs.npmjs.com/cli/v10/commands/npm-config)
 - [npm config registry](https://docs.npmjs.com/cli/v8/using-npm/registry)