# python_test
這個專案示範如何從 GitLab 套件庫(package registry)取得 Python 相依套件。

---
## 步驟

1. (非必要) 若目標GitLab專案套件庫有存取限制，請先至該專案新增access token(scope至少需包含read_api)，執行 `poetry config http-basic.gitlab <ANY_USERNAME> <PASSWORD>`設定access token。

2. 執行 `poetry sync` 安裝相依套件。