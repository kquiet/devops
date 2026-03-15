<br/><br/><br/>

# Deployment
 - K8S內建API Resource
 - 用途
    - 最常用的容器部署方式(建立Pod副本)
    - 滾動更新Pod
```yaml
# ocr-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ocr-gpu
  namespace: wormhole2
spec:
  replicas: 2 # remove this when using HorizontalPodAutoscaler
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
  selector:
    matchLabels:
      app: ocr-gpu
  template:
    metadata:
      labels:
        app: ocr-gpu
    spec:
      volumes:
        - name: ocr-model-volume
          emptyDir:
            sizeLimit: 1Gi
      initContainers: # run before main containers
        - name: download-ocr-model
          image: google/cloud-sdk:slim
          volumeMounts:
            - name: ocr-model-volume
              mountPath: /temp-volume-root
          command: # get model files from GCS to volume
            - sh
            - -c
            - |
              echo "Syncing .paddleocr from GCS..." && \
              gsutil -m rsync -r gs://wormhole2-ocr/.paddleocr /temp-volume-root/
      containers:
        - name: ocr-gpu-demo
          image: asia-east1-docker.pkg.dev/inno-yuzw03sr2f-1739864019/virtual/wormhole-ocr:0.1
          volumeMounts:
            - name: ocr-model-volume
              mountPath: /opt/.paddleocr
          env:
          - name: PADDLE_OCR_BASE_DIR
            value: "/opt/.paddleocr"
          ports:
            - containerPort: 5001
          resources:
            requests:
              memory: "512Mi"
              cpu: "100m"
              nvidia.com/gpu: 1
            limits:
              memory: "2048Mi"
              cpu: "500m"
              nvidia.com/gpu: 1
          startupProbe: # use this to indicate the status of startup
            httpGet:
              path: /docs
              port: 5001
            initialDelaySeconds: 5
            periodSeconds: 10
            failureThreshold: 3
          livenessProbe: # use this to indicate whether this pod is dead
            httpGet:
              path: /docs
              port: 5001
            initialDelaySeconds: 10
            periodSeconds: 5
            timeoutSeconds: 2
            successThreshold: 1
            failureThreshold: 3
          readinessProbe: # use this to control whether accept requests or not
            httpGet:
              path: /docs
              port: 5001
            initialDelaySeconds: 10
            periodSeconds: 5
            timeoutSeconds: 2
            successThreshold: 1
            failureThreshold: 3
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: cloud.google.com/machine-family
                operator: NotIn
                values:
                - e2
              - key: cloud.google.com/gke-accelerator
                operator: In
                values:
                - nvidia-l4
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app
                  operator: In
                  values:
                  - ocr-gpu
              topologyKey: kubernetes.io/hostname
      tolerations: # tolerate node taints
      - key: "nvidia.com/gpu"
        operator: "Exists"
        effect: "NoSchedule"
      nodeSelector: # use this to trigger automatic installation of gpu driver during node-autoprovisioing
        cloud.google.com/gke-gpu-driver-version: "default"
```
 - 如何執行(請確定沒有其它人也在維護相同物件)
 ```shell
 # merge at client-side
 kubectl apply -f ocr-deployment.yaml

 # merge at server-side
 kubectl apply --server-side -f ocr-deployment.yaml
 ```

<br/>

# Service
 - K8S內建API Resource
 - 用途
    - 提供穩定的存取入口：即使Pod重啟、IP改變，Service仍維持固定的虛擬IP(ClusterIP)
    - 實現簡單負載平衡(round robin)
    - 對外界的連接方式進行抽象化：可暴露為內部(ClusterIP)、外部(LoadBalancer)或DNS名稱(ExternalName)
```yaml
apiVersion: v1
kind: Service
metadata:
  name: ocr-gpu
  namespace: wormhole2
spec:
  selector:
    app: ocr-gpu
  ports:
    - name: http
      protocol: TCP
      port: 80
      targetPort: 5001
  type: ClusterIP
```
 - cluster內的連接方式
    - `http://ocr-gpu.wormhole2.svc.cluster.local`
    - `http://ocr-gpu.wormhole2.svc`
    - `http://ocr-gpu.wormhole2`
    - `http://ocr-gpu`
 - cluster外的連接方式(開發或除錯時使用)
   ```shell
   # forward local port XXXX to service port 80
   kubectl -n wormhole2 port-forward svc/ocr-gpu XXXX:80 
   ```

<br/><br/><br/>
<div style="display: flex; justify-content: space-between;">
  <a href="02_架構愈來愈清楚，概念愈來愈模糊.md">架構愈來愈清楚，概念愈來愈模糊</a>　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　
  <a href="04_全我監督：看著看著就長大了.md">全我監督：看著看著就長大了</a>
</div>