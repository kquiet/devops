[[_TOC_]]

---
# 系統可觀測性實作，以自建Vue.js/FastAPI應用程式為例 - Traces

## Trace架構
![trace-architecture](https://www.plantuml.com/plantuml/png/fP9DRiCW48Ntd68ku0jq4INig_O6rfXC7AlyK1WtYYhVlGG5jSYXIjEDRV6-nppys4R6mBFHmgDwmv5WvxsU5FBaR8HF0H18CTfH4poZEawMTdaPG3dZdINBu9YqSbedqWN02EPAzfMINMNE8JZBPFTzF4Sc4olRIimJgva5kUdBz9AVAmswsNURHaHuWYEphv8EwTqAMhHcpk9UkHefitHtoELMF_BkVkHZ_SW7-v6_z2CR_SZ_z2CVwaUs-YdI_I4NiGXHShuCaS873fEU-FogaGykc9peEyqOy80MUwQqSidaV5-jtQ9hBX5xP1mm4fXpVDTNENyB0JzGwFRkPBlDQaevGGs7QJnoeijcYMBbBqTitDFyavgR5vVycmip59sXVewKh_Cin0nTPKhu4Dmf0MAR-fgD_W80)

### 什麼是Trace、Span ？
- Trace: 代表一個請求或交易在分散式系統中流轉的完整旅程。
- Span: 每個span代表Trace旅程中的一個特定步驟，例如函數呼叫、資料庫查詢或 API 請求。
- Example:
  ![explain-trace](https://www.plantuml.com/plantuml/png/XP91RnCn58Jl_XMMk9G3sNjLHMsW82JWGCk1K_HiloHk7TkoduFvzzZP9DviilGOxpUZoRovZmI1qjOmuJ9_zqslDxGm2Hb8Se7_YXWuH9uOMiKBiiS-1sUfF9GVoIe8VxbTQvihk3e-CLzyjTGUBF6FOCo3ruj4vEnibx2Y4iGP15u_OTXfYN7s4Yi1yOL9PmnAqiv6_f2rwp_aipmBaAzdSLOGgTXLL5mD1DxF2Z0J2DGxWhW0Ofzc0CLBI041o98v3ZWbJlbQhR_H6FU7LO60YFmx10sV5bMm7GXOuX_chKT-o-zA1-KMmYISIwFbwrstVvdN8-aT40vgRyBY8a4qVK3LovUo88HXgQqCk4LB9yCYABfQVD79_cetxrdzNPzpULqZtNJxlzhbdBloCVyly9V7PxuXyhTTjphCfXFzlGOkfm1dySNRdjDMhPms0J5qXt4vAnrmkJTg7iS-HgWFhfvyJCVhjDnWQLsh2r2DmEGZ1XgxgWhNZOotuAn5sOvNYTvrMlFrnzFZp-TfIGr_YWVYKC1KXMrs2iTrZxS8cK4-ZEiuA0dYCBcf1QUXSsFkqQgqDVy0)

### 在frontend/backend要做的事
1. 選擇client library (建議採用opentelemetry，有automatic instrumentation)
2. 配置
   - trace exporter url，處理traces的系統位置
   - trace attributes，供後續查詢條件使用
   - auto instrumentation，自動探測otel所支援的套件traces
3. 自定義span

## gitlab原始碼
 - [前端](http://192.168.201.83:8088/zoo/devops/-/tree/main/frontend/poc-frontend)、[前端套件](http://192.168.201.83:8088/zoo/devops/-/tree/main/library/javascript/otel-integration-lib)
 - [後端](http://192.168.201.83:8088/zoo/devops/-/tree/main/backend)、[後端套件](http://192.168.201.83:8088/zoo/devops/-/tree/main/library/python/fastapi_metrics_prometheus)
 - [docker-compose](http://192.168.201.83:8088/zoo/devops/-/tree/main/scripts/poc/observability)

## View/Search Traces in Grafana