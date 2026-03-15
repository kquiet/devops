# Poetry安裝說明

## Windows 10使用者
1. 請先安裝python3環境
2. 以系統管理者權限執行Powershell
3. 執行`set-executionpolicy -executionpolicy Unrestricted -scope CurrentUser`，以開啟當前使用者執行腳本的權限
4. 執行`(Invoke-WebRequest -Uri https://install.python-poetry.org -UseBasicParsing).Content | python -`安裝poetry至獨立環境
5. 確認poetry已安裝至路徑`%APPDATA%\pypoetry`
6. 將`%APPDATA%\Python\Scripts`加到使用者環境變數Path

## Ubuntu 22.04使用者
1. 請先安裝python3環境
2. 執行`curl -sSL https://install.python-poetry.org | python3 -`安裝poetry至獨立環境
3. 確認poetry已安裝至路徑`~/.local/share/pypoetry`

# Poetry反安裝說明
## Windows 10使用者
1. 執行`(Invoke-WebRequest -Uri https://install.python-poetry.org -UseBasicParsing).Content | python - --uninstall`

## Ubuntu 22.04使用者
1. 執行執行`curl -sSL https://install.python-poetry.org | python3 - --uninstall`

## 參考文件
[Poetry官網](https://python-poetry.org/docs/#installing-with-the-official-installer)