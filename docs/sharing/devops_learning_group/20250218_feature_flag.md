[[_TOC_]]

---

# Feature Flag

## 1. 介紹

### 什麼是Feature Flag?
- Feature的開關，讓我們可以在不修改程式碼的情況下開啟或關閉功能。

```python
import asyncio
import base64
import os

from flipt import AsyncFliptClient
from flipt.evaluation import BatchEvaluationRequest, EvaluationRequest

async def voice_to_text():
  headers = {}
  username = os.getenv("FLIPT_USERNAME") or "admin"
  password = os.getenv("FLIPT_PASSWORD") or "admin"

  b64_creds = base64.b64encode(f"{username}:{password}".encode("utf-8")).decode("utf-8")
  headers["Authorization"] = f"Basic {b64_creds}')"

  flipt_client = AsyncFliptClient(headers=headers)

  boolean_flag = await flipt_client.evaluation.boolean(
    EvaluationRequest(
      namespace_key="development",
      flag_key="voice-boolean",
      entity_id="maybe_user_id",
      context={"vip-type": "company-vip"},
    )
  )

  if boolean_flag:
    print("boolean_flag(True) business logic goes from here...")
  else:
    print("boolean_flag(False) business logic goes from here...")
```

### 使用Feature Flag的理由
- **更安全的發布:** 降低新功能上線時的風險。
- **漸進式推出功能(Gradual Rollouts):** 讓新功能先給部分用戶使用(canary releases)。
- **基於角色的功能開關:** 根據使用者角色開啟特定功能（例如：只有 VIP 用戶可以使用）。
- **A/B 測試:** 比較不同版本的功能，看哪個效果比較好。
- **快速修正:** 如果某個功能出錯，可以馬上關閉它。

## 2. Feature Flag工具 - Flipt
- 開源的Feature Flag管理工具。
- 讓我們可以輕鬆開啟或關閉系統功能。
- [Flipt.io 官方文件](https://docs.flipt.io/introduction) 提供了詳細的說明與範例。

### 為什麼選擇 Flipt？
- **簡單易用：** 透過圖形化介面管理Feature Flag。
- **彈性：** 支援多種程式語言的整合。
- **支援Self-Hosted：** 可自行掌控設定資料。
- 其他選擇：LaunchDarkly、Unleash、Growthbook、FeatBit、FeatureHub。

### 如何開始使用 Flipt？
- 使用 Docker 啟動 Flipt：
  ```sh
  docker run --name flipt -d -p 8080:8080 -p 9000:9000 docker.flipt.io/flipt/flipt:latest
  ```
- 圖形化介面URL：`http://localhost:8080`

## 3. Flipt 核心概念

### 命名空間（Namespace）
- 在 Flipt 內部，所有Feature Flag設定都是透過命名空間分隔，以對應不同環境（如開發、測試、正式環境）。

### Flags
- Flags代表系統功能開關。
- **On/Off Flags：** 簡單的開啟或關閉系統功能。
- **Variant Flags：** 提供不同變體的系統功能給不同的使用者。

### 分組 (Segments)
- 透過分組來區分用戶。
- **Constraints：** 設定條件，依Context決定使用者屬於哪個Segment。

### Rules
- Rules定義Segment是對應於哪個flag variant，用來綁定Flag與Segment。

### Evaluation
- 當我們向Flipt發送請求時，Flipt會計算出對應的Flag值。Evaluation指的就是這個過程。
- **Entity ID:** Evaluation在計算Flag值時，用這個資訊進行獨特性識別(unique identification)。
- **Context:** 根據我們定義的Constraints及Context，判斷Entity屬於哪個Segment。
- **Bucketing:** 確保相同的Entity在不同時間進行Evaluation時，都會獲得相同的Flag值。 (sticky)

## 4. Flipt Live Demo
- 以語音轉文字為例。

## 5. 使用Feature Flag的注意事項
- 確保系統功能可以在不重新部署應用的情況下切換。
- 保持Flag邏輯簡單易懂。
- Flag使用清楚的名稱，如 `voice_enabled`，不要用`flag1`。
- 設定移除過時Flag的計畫，避免系統變得混亂。

## 6. 問答與討論
- Wormhole 是否需要Feature Flag解決方案？ 還是自己開發？
- 在開發流程中引入Feature Flag可能會帶來哪些變化？

## 7. 總結

### 重點回顧
- Feature Flag可以讓我們更安全、靈活地發布系統功能。
- Flipt 是一款簡單易用的Feature Flag管理工具。

### 下一步
- 各種Feature Flag工具試用。
- 討論如何整合進我們的開發流程。

## 8. 參考資料
- [Flipt 官方 GitHub](https://github.com/flipt-io/flipt)
- [Flipt server-side SDKs](https://docs.flipt.io/integration/server/rest), [Flipt client-side SDKs](https://docs.flipt.io/integration/client), [Flipt OpenFeature Providers](https://docs.flipt.io/integration/openfeature)
- [OpenFeature 官方網站](https://openfeature.dev/)