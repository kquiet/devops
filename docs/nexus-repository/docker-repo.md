[[_TOC_]]

# Docker Repository使用說明
以下連結若欲使用網域名稱的方式連線，請先[新增DNS](/docs/dns/setup.md)及[匯入受信任的根憑證授權單位(trusted root certificate authorities)](/docs/certificate/setup-root-ca.md)。

## 抓取image
| 以ip位置連線 | 以網域名稱連線 |
| ----- | ----- |
| 192.168.23.123:8082 | docker-group.repo.svc.internal |

1. 執行```docker pull 192.168.23.123:8082/xxx/yyy:zzz```

## 發佈image
| 以ip位置連線 | 以網域名稱連線 |
| ----- | ----- |
| 192.168.23.123:8083 | docker-internal.repo.svc.internal |

1. 執行 ```docker login 192.168.23.123:8083```
2. 輸入AD帳密，登入成功會看到類似文字：```Login Succeeded```
3. 上傳image： ```docker push 192.168.23.123:8083/xxx/yyy:zzz```

## Q&A 
1. 使用 `docker login/pull`連線到 192.168.23.123:808x 時發生`http: server gave HTTP response to HTTPS client` 的錯誤
    - 原因：docker client 必須以https的方式連線至repository
    - 解決方式:修改`/etc/docker/daemon.json`，加入以下配置
    ```json
    {
      "insecure-registries": ["192.168.23.123:8082", "192.168.23.123:8083"]
    }
    ```
2. 在windows電腦使用podman desktop連線到`docker-xxx.repo.svc.internal`遇到無法識別憑證的問題
    - 解決方式：參考[這裡](https://github.com/containers/podman/blob/main/docs/tutorials/podman-install-certificate-authority.md)，將根憑證放入podman machine。根憑證檔案下載方式可參考[這裡](/docs/certificate/setup-root-ca.md)。

## 參考連結
 - [docker daemon.json](https://docs.docker.com/engine/daemon/)
 - [dockerd設定](https://docs.docker.com/reference/cli/dockerd/#daemon-configuration-file)