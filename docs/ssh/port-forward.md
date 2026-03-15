[[_TOC_]]
## 簡介
### SSH Port Forward (Local Port Forwarding)
將本地機器的指定埠號(port)轉發到遠端機器上的特定埠號，允許本地應用通過該埠號訪問遠端資源。常用於安全地通過SSH隧道訪問遠端機器上的內部網路資源。

#### 適合使用的場景
 - 需要從本地訪問遠端資源，例如在本地瀏覽器中訪問位於內網的網站。
 - 在本地開發環境中測試遠端服務（例如，遠端資料庫或API服務）。
 - 保護本地與遠端服務之間的資料通訊(通過SSH加密訪問遠端服務)。

#### 不適合的場景
 - 可以直接使用VPN連線時。因為VPN提供更廣泛的網路覆蓋，而本地轉發僅針對特定的ports。
 - 需要從多個網路節點訪問遠端資源，因為本地轉發僅限於單個設備使用。

### SSH Remote Port Forward
將遠端機器的指定埠號(port)轉發到本地機器的特定埠號，允許遠端機器上的應用通過該埠號訪問本地資源。常用於允許遠端機器反向訪問本地服務，例如將遠端請求轉發到本地的Web服務。

#### 適合使用的場景
 - 讓遠端能夠訪問本地資源，例如將內網服務暴露給遠端主機使用。
 - 允許遠端客戶端通過SSH訪問本地服務，適合需要分享本地服務給遠端客戶端的情況。

#### 不適合的場景
 - 當需要持續的高性能網路連接時，遠端轉發的性能可能受到影響，不如專門的網路架構穩定。
 - 無法應對高流量需求的應用場景，因為SSH轉發不適合大規模高頻率的網路通訊。

## 網路通訊架構範例
![ssh-direct](https://www.plantuml.com/plantuml/png/SoWkIImgAStDuKhEoIzDKNY-RTEBxUiT5Qgv580WEJ-t83ylDQz4uUNitIzQbpaQAIGMAoGQeKag5sJcPSEK68AL68AK05KgwEhQ8V5iT7L1l5ek5EkS5AhncEW4DZ794AkBd8p0aX0N9O6jWobDWbYN1BOkqL01BADWfL1SdA5XPAJ9vP2QbmBqE000)

電腦A1僅可透過ssh連線至電腦B1

### 情境1
 - __想讓電腦A1能夠用本地的瀏覽器看電腦B1的前端網頁__
#### 方法1：在電腦A1用ssh建立local port forward
```shell
# 第1個80是指在電腦A1開啟port 80
# (linux環境下，要開啟小於1024的port需要以root權限執行)
# localhost:80 是指透過電腦B1去連線的位址 
ssh -i /path/to/your_private_key -L 80:localhost:80 -p 22 someuser@B1
```
#### 方法2：在電腦A1用putty建立local port forward 
1. 開啟putty
2. 點選"Session" -> "Host Name"輸入`B1` -> "Port"輸入`22`
3. 點選展開"Connection" -> 點選"Data" -> "Auto-login username"輸入*someuser*
4. 點選展開"Connection"/"SSH"/"Auth" -> 點選"Credentials -> "Private key file for authentication:"選擇*your_private_key*
5. 點選"Connection"/"SSH"/"Auth"/"Tunnels" -> (要讓電腦A2能夠使用電腦A1所開啟的port的話，請勾選"Local ports accept connections from other hosts") -> "Source port"輸入`80` -> "Destination"輸入`localhost:80` -> 點選"Local" -> 點選"Auto" -> 點擊"Add"
6. 點選"Session" -> "Saved Sessions"輸入*preferred_name* -> 點擊"Save" 保存前述設定
7. 選擇前一步驟保存的session -> 點擊 "Open" 即可建立ssh tunnel(local port forward)

### 情境2
 - __想讓電腦B1能夠在本地使用電腦A1開發中的前端網頁(不需要部署前端網頁到電腦B1)__
 - __想讓電腦B1能夠使用電腦A2的任何服務(只限透過A1能連得上的服務)__
#### 方法1：在電腦A1用ssh建立remote port forward
```shell
# 第1個2222是指在電腦B1開啟port 2222
# (linux環境下，要開啟遠端主機小於1024的port需要以root帳號進行ssh連線)
# localhost:80 是指透過電腦A1去連線的位址
#
# 第1個8088是指在電腦B1開啟port 8088
# A2:8088 是指透過電腦A1去連線的位址
# sudo socat這段指令的作用是在B1將port 80轉到port 2222，間接以非root帳號達到開啟B1 port 80的目的
ssh -i /path/to/your_private_key -R 2222:localhost:80 -R 8088:A2:8088 -p 22 someuser@B1 "sudo socat TCP-LISTEN:80,reuseaddr,fork,keepalive,bind=127.0.0.1 TCP:localhost:2222,retry=3"
```
#### 方法2：在電腦A1用putty建立remote port forward 
1. 開啟putty
2. 點選"Session" -> "Host Name"輸入`B1` -> "Port"輸入`22`
3. 點選展開"Connection" -> 點選"Data" -> "Auto-login username"輸入*someuser*
4. 點選展開"Connection"/"SSH"/"Auth" -> 點選"Credentials -> "Private key file for authentication:"選擇*your_private_key*
5. 點選"Connection"/"SSH" -> "Remote command"輸入`sudo socat TCP-LISTEN:80,reuseaddr,fork,keepalive,bind=127.0.0.1 TCP:localhost:2222,retry=3`
6. 點選"Connection"/"SSH"/"Auth"/"Tunnels" -> "Source port"輸入`2222` -> "Destination"輸入`localhost:80` -> 點選"Remote" -> 點選"Auto" -> 點擊"Add"
7. 點選"Connection"/"SSH"/"Auth"/"Tunnels" -> "Source port"輸入`8088` -> "Destination"輸入`A2:8088` -> 點選"Remote" -> 點選"Auto" -> 點擊"Add"
8. 點選"Session" -> "Saved Sessions"輸入*preferred_name* -> 點擊"Save" 保存前述設定
9. 選擇前一步驟保存的session -> 點擊 "Open" 即可建立ssh tunnel(remote port forward)

## 複雜狀況
![ssh-jump](https://www.plantuml.com/plantuml/png/VLB1IiD05BplLmpaO3qaPFTKeaYJGdz3jiaMGzFTaDrYeNZqAxnx5JpemG-o_eLlTmrKBTrJvisyUJEGcNLoSDjDn-hER1jylhqUtbzAx1derMRJ6wsqmzVJn-7nkHIG5bBy8PE-rUjHmeE4UmafaQOtH-WwJJrwOB_EpR4_upWFZlM_hUhiLXMsblnaZqe4ClPOnf1HwX659EJFQUDKjBcrzWv9dfVbOi50ipKebpCmlTBepU2memUf6wpCS2-7nhCLlx2H5O8fuhnZz2MwXrdvOa2hdHgqx89sD2Y8u1ccEKc3-v63vA3CDKS1IZQPvfUCGAWHHwF9H0XFKIbF9LshLH5hN3crSp_VSITeIPLbY8tPZ2xIp_4D)