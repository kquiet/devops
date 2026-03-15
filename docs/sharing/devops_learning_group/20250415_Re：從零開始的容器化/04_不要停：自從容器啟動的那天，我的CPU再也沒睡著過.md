<br/><br/><br/>

# 建立/運行容器
## 命令式(Imperative)
```shell
docker run -d \
  --name wormhole-ocr \
  --restart always \
  -e PADDLE_OCR_BASE_DIR=/opt/.paddleocr \
  -v ~/.paddleocr:/opt/.paddleocr \
  -p 5001:8080 \
  --gpus '"device=0,1"' \
  --cpus=2 \
  --memory=2g \
  wormhole-ocr:0.1
```

## 宣告式(Declarative)
```yaml
# docker-compose.yml
services:
  wormhole-ocr:
    image: wormhole-ocr:0.1
    container_name: wormhole-ocr
    restart: always
    deploy:
      resources:
        reservations:
          devices:
            - capabilities: [gpu]
              driver: nvidia
              device_ids: ['0', '1']
              #count: all
        limits:
          cpus: '2'
          memory: 2G
    environment:
      # need at least paddleocr v2.10.0 to support below configuration
      PADDLE_OCR_BASE_DIR: /opt/.paddleocr
    volumes:
      - ~/.paddleocr:/opt/.paddleocr
    ports:
      - "5001:8080"
```
```shell
# run in the background
docker compose up -d
```
## 在docker容器內使用nvidia gpu的前置作業
 - [安裝gpu driver](https://www.nvidia.com/en-us/drivers/)
 - [安裝nvidia container toolkit & 設定 for docker](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)

<br/><br/><br/>
<div style="display: flex; justify-content: space-between;">
  <a href="03_這不是我寫的Dockerfile，但它的錯是我來debug的.md">這不是我寫的Dockerfile，但它的錯是我來debug的</a>　　　　　　　　　　　　　　　　　　　　　　　　　　
  <a href="05_我以為容器只是工具，結果它要重構我的開發環境.md">我以為容器只是工具，結果它要重構我的開發環境</a>
</div>