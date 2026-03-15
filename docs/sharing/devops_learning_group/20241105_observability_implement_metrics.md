[[_TOC_]]

---
# 系統可觀測性實作，以自建Vue.js/FastAPI應用程式為例 - Metrics

## Metric架構
![metric-architecture](https://www.plantuml.com/plantuml/png/fPDDRi8m48NtFiLSW0kmgC3xghr1D34ciUeVrvuKeOgxrxAS4XT7GkaAcFdUcwU7V8Y4WIQZcKVnWOE4e_TQ2IJbR8Hl1X2a8BI3bl2AObHM7lCOG3ZZdPMMm97KmccTI1S08vX2TjKcg-Oxv-0iINlguZMIDB6IFIppnUhcZ3HrXNwOm-vb9HliOIJoMNYhWlRfSordlMl5B4HBzNlhrcgPFzqotzOotzWoNscPjrhc_s-PRsgPDrg-CJQVU-kZ35_OAwte-gwHpYwOR7mtzS4PIQESSXhdk_iWSISax35A60AUqM9db56XaDMiCYsRcblQcMlyr6MTlpC62nHs9tUngU0gpznhJGOrZ9JGsIbH939KQJDHHovsgR0_wFBzpAKNU1tbJw3jL_cCTrk0-LTCacwAClyl4sDJbYuwsaCVt2K1x93oJKR_0000)
### 在frontend/backend要做的事
1. 選擇client library (建議採用與prometheus相容的)
2. 使用適當的Metrics類型
   - Counter: 發生次數
   - Gauge: 當前數值
   - Histogram: 數據的分佈狀況
3. 將單一Metrics分類 (e.g.: by labels)

## gitlab原始碼
 - [前端](http://192.168.201.83:8088/zoo/devops/-/tree/main/frontend/poc-frontend)、[前端套件](http://192.168.201.83:8088/zoo/devops/-/tree/main/library/javascript/otel-integration-lib)
 - [後端](http://192.168.201.83:8088/zoo/devops/-/tree/main/backend)、[後端套件](http://192.168.201.83:8088/zoo/devops/-/tree/main/library/python/fastapi_metrics_prometheus)
 - [docker-compose](http://192.168.201.83:8088/zoo/devops/-/tree/main/scripts/poc/observability)

## View/Search Metrics in Grafana