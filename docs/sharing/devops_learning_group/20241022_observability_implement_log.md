[[_TOC_]]

---
# 系統可觀測性實作，以自建FastAPI應用程式為例 - Log
## 系統可觀測性簡介
系統可觀測性（Observability）是指了解系統內部狀態的能力。簡單來說，就是透過收集和分析各種資料（如日誌logs、指標metrics、追蹤traces等），以了解系統如何運作、診斷問題、找出性能瓶頸，並確保系統正常運行。這種資料能幫助工程師快速定位問題，提升系統穩定性和性能。

舉個例子，當一個應用程式出現錯誤時，透過良好的可觀測性，工程師能夠迅速從日誌（logs）中找到錯誤訊息，從指標（metrics）中看出效能狀況，或者透過追蹤（traces）了解請求的路徑，進而快速解決問題並優化系統。

## Log架構
![log-architecture](https://www.plantuml.com/plantuml/png/dPDThjem48NVlOhP01leGmL-hzeTH1Cp2HR-SUq925NilIPoAUGQSs-U4ddEEUEPJzucniYJDIAWEk98i0l1Q8MilKlmHm14KenkD0G_K1sqezry3F3FCKJlcDo-IvV4P1DW0bkatR9Ol03As-0TERxxgxvPVNtgr-VlgtQbrkXM53NN1wrdCieRGufzhFPvKXJ_e0s1yMDtycQoLFNbSYhoPGqsUtzsc-zr4to3SzHCnTo-qDkeIFX_mzSQRFbvs78bRBaEjbm5MtuPjbm9MpPWorUmPHjswqALg2RigxY_-PzzedZ2NXlDbry6UV3HvdK-hcUCEA3377RKjobzw1wFQjfdMLRiaR77H60lwRSfvVbVm8CIDdcAHNw-_u4vL7Gb8GjOXTjKE6yZUKlTb6X6EGdnxgLCuNNJzkBRNZ4jnic5FlfpeYYsEMkovYy0)
### 在FastAPI(backend)要做的事
1. 設定logging framework library
   - [格式](https://docs.python.org/3/howto/logging.html#formatters)
   - log目的地(e.g.: stdout/file/[external system](https://docs.python.org/3/library/logging.handlers.html))
2. 寫log(錯誤、事件、狀態、與外部應用程式的互動資訊)
   - 不寫敏感性資料(具識別性質的個資、密碼、金融或付款資訊、應用程式機密)
   - 不寫大筆資料(e.g.: greater than 32K)
   - 不寫環境變數(或放到較低log層級e.g.: debug)
   - 不寫根本不看或看不懂的資訊
   - 儘量不寫執行時間(交給traces)
   - 儘量不寫指標性資料(交給metrics)

## gitlab原始碼
 - [後端](http://192.168.201.83:8088/zoo/devops/-/tree/main/backend)
 - [docker-compose](http://192.168.201.83:8088/zoo/devops/-/tree/main/scripts/poc/observability)

## View/Search Log in Grafana