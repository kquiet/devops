[[_TOC_]]

## 1. 如何透過Google Cloud Storage上傳檔案、分享檔案給任何人(不需google帳密即可下載)
### 無下載期限
1. [建立](https://console.cloud.google.com/storage/browser) Buckets (需注意Location Type, Hierarchical Namespace)
2. (非必要) 設定可存取檔案的IP位址
3. 設定 `Storage Object Viewer` 權限給 `allUsers`
4. Copy `Public URL` 給要下載檔案的人
### 有下載期限
1. [建立](https://console.cloud.google.com/storage/browser) Buckets
2. [新增](https://console.cloud.google.com/iam-admin/serviceaccounts) Service account
3. [新增](https://console.cloud.google.com/iam-admin/iam) `Storage Bucket Viewer (Beta)`, `Storage Object Viewer` 權限給 Service account
4. [新增](https://console.cloud.google.com/iam-admin/serviceaccounts) `Service Account Token Creator` 權限給欲透過 Service account 執行(impersonate) `產出signed url` 操作的使用者帳號
5. 啟動 `Activate Cloud Shell` ，輸入指令
    ```
    gcloud storage sign-url --impersonate-service-account=${SERVICE_ACCOUNT} --duration=${下載期限:-10m} ${檔案的gsutil URI}
    ```
6. Copy `signed_url` 給要下載檔案的人
7. [Cloud Storage收費參考](https://cloud.google.com/storage/pricing)


## 2. 如何使用Google Artifact Registry (docker, python)
1. [建立](https://console.cloud.google.com/artifacts) Repository
2. (非必要) 設定 `Artifact Registry Reader` 權限給 `allUsers` (for pull)
3. 設定 `Artifact Registry Create-on-Push Writer` 權限 (for push)
    - [新增](https://console.cloud.google.com/iam-admin/serviceaccounts) Service account
    - [新增](https://console.cloud.google.com/iam-admin/iam) `Artifact Registry Create-on-Push Writer` 權限給 Service account
4. [新增並下載](https://console.cloud.google.com/iam-admin/serviceaccounts) Service account key 供後續存取 repository(僅出現1次，請妥善保存，不見了需建立新的)
    - [docker](https://docs.cloud.google.com/artifact-registry/docs/docker/authentication#json-key)
    - [python](https://docs.cloud.google.com/artifact-registry/docs/python/authentication#sa-key)
        - 使用pip安裝套件
          ```
          pip install ${PACKAGE} --index-url https://_json_key_base64:${KEY}${LOCATION}-python.pkg.dev/${PROJECT}/${REPO}/simple/
          ```
5. [Artifact Registry收費參考](https://cloud.google.com/artifact-registry/pricing)