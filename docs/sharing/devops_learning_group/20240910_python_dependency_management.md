[[_TOC_]]

---
# Python依賴管理，以Wormhole後端系統為例
## 現狀
[requirements_local.txt](20240910_requirements_local.txt)
這個檔案是在**某環境**執行以下指令產生
```bash
pip freeze > requirements_local.txt
```
在新環境執行以下指令可安裝所有依賴套件
```bash
pip install -r requirements_local.txt
```
## 問題
1. 執行```pip install -r requirements_local.txt```會顯示套件衝突導致無法安裝所有依賴套件。可參考[解決方法](https://idagile.atlassian.net/browse/AS-1259)解決衝突問題，但**解決此問題的時間點已從開發階段往後遞延、且解決方法不存在於原始碼儲存庫**。
2. requirements_local.txt包含了專案的直接相依套件及其間接相依套件，若未定期清理，長久下來這個檔案容易變得越來越大、```pip install -r requirements_local.txt```花費時間只增不減。
3. **某環境**是可信賴的環境嗎? 會不會有手動執行```pip install/uninstall xxx```，但忘記更新requirements_local.txt的狀況? 又或者更新後沒有做過衝突檢測```pip check```?

## 解決方法
1. 需要一個地方記錄專案所需的直接相依套件資訊。工程師只需在開發階段維護此處的套件資訊、處理套件衝突問題。
2. 需要一個工具可以解析依賴套件的依賴套件，並提供類似```pip install```的功能安裝專案所有套件。
3. 需要一個工具可以幫助同步環境中的已安裝套件與專案實際所需依賴套件。

## 工具選擇
### Poetry
Poetry is a tool for dependency management and packaging in Python.  It allows you to declare the libraries your project depends on and it will manage (install/update) them for you. Poetry offers a lockfile to ensure repeatable installs, and can build your project for distribution.

### Hatch
Hatch is a modern, extensible Python project manager.

| Feature | Poetry(v2) | Hatch |
|---------|--------|-------|
| **Dependency Management** | Manages dependencies using `pyproject.toml` | Manages dependencies using `pyproject.toml` |
| **PEP Compatibility** | | |
| - Package naming | Allows capitals and underscores in package names, not fully compliant with PEP 508 naming conventions | Follows PEP 508 recommendations |
| - pyproject.toml format | Custom format, not fully PEP 621 compliant | Fully PEP 621 compliant |
| - Version format | Uses custom `^` operator, not fully PEP 440 compliant | Fully PEP 440 compliant |
| - Build Backend | Uses its own build backend, not fully compliant with PEP 517 | Flexible, supports various backends including its own (hatchling) |
| **Lock File Support** | Uses `poetry.lock` | Can generate environment-specific lock files |
| **Environment Management** | Single environment per project | Multiple named environments |
| Dependency Installation | `poetry install` | `hatch env create` |
| **Dependency Tree Display** | `poetry show --tree` | none |
| **Sync pyproject.toml and venv** | `poetry sync` | none |
| Matrix Testing | No built-in support for matrix testing. It typically relies on CI configuration. | Built-in support via environments |
| Script Definitions | `[tool.poetry.scripts]` | `[tool.hatch.envs.<env>.scripts]` |
| Version Bumping | `poetry version` | `hatch version` |

## Poetry依賴管理概念
![poetry-manage-dependency](https://www.plantuml.com/plantuml/png/TP1HIiH038RVSufSm5tqiRJ3taDyYDDOHjDCITE58jxTcN4BAknJal-Ra8-vh4xcson0qRCXwvIKsP1Mt5OsC8vEEWdZb1m_uIsLTjaNo--5d3pFKj_UvXlExBQV9CUFocg5BuXa8rvJkKR2UiLdGCGZGDRIPPrPlUN3CBGwyi8wiiRzyT_y12y0rH4Vmd4VEvn9QM8uWiAQHuTz2dtCagrxbOt3ZsI3_RdbeJ-d03KeMxzCx-ucNPr4_gnVYbtvpcy0)
### 常用指令
| 用途 | 指令 |
| --- | --- |
| 新增/刪除xxx套件至pyproject.toml、poetry.lock，並異動至虛擬環境 | poetry add/remove xxx |
| 新增/刪除xxx套件至pyproject.toml、poetry.lock，不異動至虛擬環境 | poetry add/remove --lock xxx |
| 根據pyproject.toml，更新套件資訊至 poetry.lock | poetry lock |
| 根據poetry.lock，安裝套件至虛擬環境 | poetry install |
| 根據poetry.lock，同步套件至虛擬環境 | poetry sync |
| 根據poetry.lock，同步套件至虛擬環境，包含optional group XXX所定義的套件 | poetry sync --with XXX |
| 根據poetry.lock，同步套件至虛擬環境，但不包含group XXX所定義的套件 | poetry sync --without XXX |
| 根據poetry.lock，同步套件至虛擬環境，僅包含group XXX所定義的套件 | poetry sync --only XXX |
| 產出 pip requirements list(需安裝poetry export插件) | poetry export -f requirements.txt --output requirements_local.txt |
| 顯示依賴樹 | poetry show --tree |
| 在虛擬環境執行指令 | poetry run XXXX |

## 與Devops的關聯…
- 處理套件衝突的方法除了開發階段需要，建置(build)階段也需要
- CI 需要自動進版號的功能: ```poetry version```
- 建置的指令可存放在與管理依賴套件相同的地方，讓所有想知道的工程師都能知道