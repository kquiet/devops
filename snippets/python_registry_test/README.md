# python_registry_test
這個專案示範如何使用 GitLab CI Pipeline，將 Python 套件發佈到 GitLab 套件庫(package registry)。

---
## 如何自動發佈
### `.gitlab-ci.yml` 檔案簡介

這個 `.gitlab-ci.yml` 檔案定義了專案的 GitLab CI Pipeline，其主要功能是自動化執行測試與發佈流程。

#### 工作流程(workflow)觸發條件

* 如果提交標題（commit title）以 `nocicd` 開頭，則 CI Pipeline將不會被觸發。
* 如果提交是發生在預設分支（例如 `main` 或 `master`）上，且 `pyproject.toml` 或 `python_registry_test` 資料夾下的任何檔案有變動時，CI Pipeline會自動啟動。

#### `sync-test-publish` 工作 (job)

這是pipeline主要執行的工作，屬於 `publish` 階段，其詳細設定如下：

* **映像檔 (image):** 使用自建映像檔Repo的`docker-group.repo.svc.internal/python:3.12.10-bookworm-poetry2.1.4` 作為運行映像檔。
* **標籤 (tag):** 指定符合特定標籤的gitlab runner運行此工作。
* **快取 (cache):** 為了提升執行效率，pipeline會快取 `.venv` 和 `.poetry` 資料夾，避免重複安裝相依套件。
* **變數 (variables):** 設定了 Poetry 相關環境變數，包含 Poetry 的安裝路徑以及用於套件發佈的密碼。此密碼需至專案Settings -> Repository -> Deploy tokens 新增名為"gitlab-deploy-token"的部署用token (Scopes需包含write_package_registry)。
* **腳本 (script):** 依序執行以下命令：
    1.  `poetry sync`: 同步專案相依套件，確保所有必要套件均已安裝。
    2.  `poetry poe test-coverage`: 執行單元測試並產生測試覆蓋率報告。
    3.  `poetry poe publish`: 執行專案套件的發佈。

---
### `pyproject.toml` 檔案簡介
#### 套件(package)與依賴(dependency)管理
本專案套件包含 `python_registry_test` 目錄下的所有檔案。

* **測試依賴**：專門用於測試的套件，例如 `pytest` 和 `pytest-cov`。
* **套件來源 (Source)**：
  * 設定了一個名為 `gitlab` 的套件來源，其 URL 指向本專案的PyPI套件庫。
  * `priority = "explicit"` 表示這個來源僅在明確指定時才會被使用。

#### 測試設定
* **Pytest 設定**：
  * **測試路徑**：`tests` 目錄。
  * **測試檔案**：檔案名稱以 `test_` 開頭。
  * **測試類別/函式**：類別名稱以 `Test` 開頭，函式名稱以 `test_` 開頭。
  * **額外選項**：`-rA`，顯示所有測試結果。

#### 自動化任務(Poe)
使用 `poethepoet` 插件來定義和執行自動化任務。

* **`test`**：執行 `pytest` 測試。
* **`test-coverage`**：執行測試並計算程式碼覆蓋率。
* **`publish`**：
  * 根據作業系統 (Linux 或 Windows) 來執行發佈命令。
  * 會先移除 `dist` 目錄，然後使用 `poetry publish` 指令將專案發佈到名為 `gitlab` 的套件來源。
