[[_TOC_]]

## GKE簡介
Google Kubernetes Engine (GKE) 是 Google Cloud提供的Kubernetes (K8S)服務。它提供GUI的介面，讓我們能夠部署、管理及擴展容器化應用程式而無需自行維護 K8S。GKE 自動化了許多任務（例如叢集配置、升級、節點管理等），讓開發人員能專注於應用程式本身，而非底層基礎設施。這使得在大規模運行容器化應用變得更容易，且內建對網路、負載平衡和自動擴展的支援。

## GKE與擴展相關的K8S資源
GKE使用各種資源來定義和管理應用程式，包括:
### 一般K8S資源
- **Pod**: K8S中的基本運行單位，可包含一個或多個容器(container)；同一pod內的各container共享網路與儲存。
- **Deployments**: Deployment描述了如何運行Pod、管理Pod副本(replica)及滾動更新(rolling update)。
- **Pod Disruption Budget (PDB)**: PDB 描述了Pod可被中斷([voluntary disruption](https://kubernetes.io/docs/concepts/workloads/pods/disruptions/))的條件限制: 一次能中斷多少個 Pod，確保應用在節點維護或更新時不會全掛掉。
- **Horizontal Pod Autoscaler (HPA)**: HPA 描述了如何依據CPU、記憶體負載及自訂指標(metrics)，自動增加或減少Pod數量，確保能承受流量變化。
- **Vertical Pod Autoscaler (VPA)**: VPA 描述了如何依據CPU、記憶體負載，自動調整Pod的CPU 和記憶體資源，提升運行效率。
- **Service**: Service描述了如何為一組Pod提供一個固定的存取方式，即使 Pod 變動，K8S的外部或內部系統都能穩定存取這些Pod。

### GKE特有資源
- **Pod Monitoring**: GCP提供了[Prometheus服務](https://cloud.google.com/stackdriver/docs/managed-prometheus)。`PodMonitoring`描述了如何採集Pod Metrics，並將其傳送至Google Cloud Monitoring平台儲存。

### 範例資源YAML
#### 1. Deployment + Horizontal Pod Autoscaler (HPA)
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: autoscale-demo
  namespace: devops
  labels:
    app: autoscale-demo
spec:
  selector:
    matchLabels:
      app: autoscale-demo
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 1
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: autoscale-demo
    spec:
      containers:
      - name: autoscale-demo
        image: gcr.io/wormhold-proj-id/autoscale-demo:v1
        resources:
          requests:
            memory: "1024Mi"
            cpu: "10m"
          limits:
            memory: "1024Mi"
            cpu: "1000m"
        ports:
        - name: http
          containerPort: 63101
        livenessProbe:
          httpGet:
            path: /metrics
            port: 63101
          initialDelaySeconds: 1
          periodSeconds: 5
          timeoutSeconds: 3
          successThreshold: 1
          failureThreshold: 1
        readinessProbe  :
          httpGet:
            path: /metrics
            port: 63101
          initialDelaySeconds: 1
          periodSeconds: 5
          timeoutSeconds: 3
          successThreshold: 1
          failureThreshold: 1
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app
                  operator: In
                  values:
                  - autoscale-demo
              topologyKey: topology.kubernetes.io/zone
      restartPolicy: Always
      terminationGracePeriodSeconds: 5
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: autoscale-demo
  namespace: devops
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: autoscale-demo
  minReplicas: 1
  maxReplicas: 10
  behavior:
    scaleDown:
      policies:
      - periodSeconds: 60
        type: Pods
        value: 2
      - periodSeconds: 60
        type: Percent
        value: 20
      selectPolicy: Min
      stabilizationWindowSeconds: 300
    scaleUp:
      policies:
      - periodSeconds: 60
        type: Pods
        value: 2
      - periodSeconds: 60
        type: Percent
        value: 20
      selectPolicy: Max
      stabilizationWindowSeconds: 0
  metrics:
  - type: Pods
    pods:
      metric:
        name: prometheus.googleapis.com|gpu_utilization|gauge
      target:
        type: AverageValue
        averageValue: 20
  - type: Pods
    pods:
      metric:
        name: prometheus.googleapis.com|active_connections|gauge
      target:
        type: AverageValue
        averageValue: 40
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 60
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 70
```
**說明:**
 - Deployment一開始只運行1個副本(預設)。
 - HPA被配置為監控兩個Resource metrics：CPU使用率（門檻值為所有Pod平均60%）、記憶體使用率(門檻值為所有Pod平均70%)以及自訂Metrics（例如來自Prometheus 的 `active_connections`），以決定何時進行擴展。如果這些指標有任一超過門檻值，K8S將根據會增加Pod數量（最多到10個副本）。當指標下降時，K8S會將Pod數量縮減，但不會少於 1 個副本。

#### 2. Vertical Pod Autoscaler (VPA)
```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: autoscale-demo
  namespace: devops
spec:
  targetRef:
    apiVersion: "apps/v1"
    kind: Deployment
    name: autoscale-demo
  updatePolicy:
    updateMode: "Off"
```
**說明:** VPA會根據[updateMode](https://github.com/kubernetes/autoscaler/blob/master/vertical-pod-autoscaler/docs/quickstart.md)決定如何調整新增/既有Pod的resource request值。使用上需盡量避免與監控CPU & Memory的HPA搭配，以免造成非預期的擴展。

#### 3. Pod Disruption Budget (PDB)
```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: autoscale-demo
  namespace: devops
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app: autoscale-demo
```
**說明:** 此PDB要求在中斷([voluntary disruption](https://kubernetes.io/docs/concepts/workloads/pods/disruptions/))期間，至少保留1個 `autoscale-demo` Pod運行。實際上，這意味著如果一個節點因維護或更新而被排空(drain)，Kubernetes不會驅逐(evict)最後一個 `autoscale-demo` Pod（因為 `minAvailable: 1`）。假設有3個副本運行，`minAvailable: 1` 意味著 Kubernetes 可以一次驅逐最多2個Pod，但在其中一個Pod恢復之前，不會驅逐第三個。通過定義 PDB，可以在叢集操作期間也能保證應用程式的基本可用性。

#### 4. Service
```yaml
apiVersion: v1
kind: Service
metadata:
  name: autoscale-demo
  namespace: devops
spec:
  selector:
    app: autoscale-demo
  ports:
  - name: http
    protocol: TCP
    port: 63101
    targetPort: 63101
  type: ClusterIP
```
**說明:** 此Service為ClusterIP 類型(預設)，GKE會配置一個ip給此Service。Service port `63101`的流量會被轉發至pod的port `63101`。selector`app: autoscale-demo`確保Service是作用在正確的Pod。用戶可以通過Service的ip 存取其背後的應用程式(pod)；Service會在可用的Pod之中分配request。這將client端所使用的endpoint與Pod的動態擴展解耦 —— 不論HPA建立或刪除多少Pod，Service 都能穩定地轉發request。

#### 5. PodMonitoring
```yaml
apiVersion: monitoring.googleapis.com/v1
kind: PodMonitoring
metadata:
  name: autoscale-demo
  namespace: devops
  labels:
    app: autoscale-demo
spec:
  selector:
    matchLabels:
      app: autoscale-demo
  endpoints:
  - port: http
    path: /metrics
    interval: 5s
```
**說明:** 此配置告訴 GKE 管理的 Prometheus 去抓取 `autoscale-demo` Pod 上的 /`metrics` 端點（假設應用程式在該端點提供 Prometheus 度量）。`selector` 使用與 Deployment 相同的標籤，因此可以發現所有該應用程式的 Pod。`endpoints` 部分指定了抓取的埠和路徑；在這個例子中，Pod 的容器應該有一個名為 "http-metrics" 的埠來提供 Prometheus 度量。通過應用此配置，應用程式的度量（例如 HPA 所使用的自訂 `active_connections`）將被收集，並傳送至 Cloud Monitoring，你可以在那裡建立儀表板或警報。這個範例展示了如何只透過一個 YAML 資源在 GKE 上設置監控，而無需自行部署完整的 Prometheus 堆疊。

#### 6. Deployment + HPA (gpu)
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: autoscale-gpu-demo
  namespace: devops
spec:
  selector:
    matchLabels:
      app: autoscale-gpu-demo
  template:
    metadata:
      labels:
        app: autoscale-gpu-demo
    spec:
      containers:
        - name: autoscale-gpu-demo
          image: nvidia/cuda:12.2.2-runtime-ubuntu22.04
          command: ["bash", "-c", "while true; do sleep 1; done"]
          resources:
            requests:
              memory: "1024Mi"
              cpu: "10m"
              nvidia.com/gpu: 1
            limits:
              memory: "2048Mi"
              cpu: "100m"
              nvidia.com/gpu: 1
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: goog-gke-node-pool-provisioning-model
                operator: NotIn
                values:
                - spot
              - key: cloud.google.com/gke-accelerator
                operator: In
                values:
                - nvidia-tesla-t4
        podAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
                - autoscale-demo
            topologyKey: topology.kubernetes.io/zone
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app
                  operator: In
                  values:
                  - autoscale-gpu-demo
              topologyKey: topology.kubernetes.io/zone
      tolerations:
      - key: "nvidia.com/gpu"
        operator: "Exists"
        effect: "NoSchedule"
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: autoscale-gpu-demo
  namespace: devops
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: autoscale-gpu-demo
  minReplicas: 1
  maxReplicas: 4
  behavior:
    scaleDown:
      policies:
      - periodSeconds: 60
        type: Pods
        value: 1
      - periodSeconds: 60
        type: Percent
        value: 20
      selectPolicy: Min
      stabilizationWindowSeconds: 300
    scaleUp:
      policies:
      - periodSeconds: 60
        type: Pods
        value: 1
      - periodSeconds: 60
        type: Percent
        value: 20
      selectPolicy: Max
      stabilizationWindowSeconds: 0
  metrics:
  - type: Pods
    pods:
      metric:
        name: prometheus.googleapis.com|DCGM_FI_PROF_GR_ENGINE_ACTIVE|gauge
      target:
        type: AverageValue
        averageValue: 20
```
**說明:**
 - Deployment: `resources` 部分在請求和限制中都包含了 `nvidia.com/gpu: 1`，這告訴K8S每個Pod需要從節點上獲取1個 GPU。GKE的GPU節點通常會被標記GPU類型（例如 `nvidia-tesla-t4`）並設有污點([taint](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/))，避免不需要GPU的Pod被安排至這些節點；需要GPU的Pod必須設定`tolerations`以被調度到有 `nvidia.com/gpu`污點(taint)的節點上。`nodeAffinity`設定可確保Pod被放置在擁有 NVIDIA T4 GPU的節點上。
 - HPA: 被配置為監控：GPU使用率（門檻值為所有Pod平均20%），以決定何時進行擴展。如果指標超過門檻值，K8S將根據會增加Pod數量（最多到4個副本)。

## GKE Cluster Autoscaling
GKE提供 **Cluster Autoscaler**，可根據工作負載需求自動調整節點數量，確保資源充足但不浪費。
 - **當資源不足時擴展**：若Pod因資源不足無法被排程（例如 CPU、記憶體不足），Cluster Autoscaler會自動新增節點。
 - **當節點閒置時縮減**：若節點上的Pod可以遷移至其他節點，並且該節點長時間閒置，Cluster Autoscaler會自動移除節點以節省成本。

### 如何設定 GKE Cluster Autoscaler？
[透過管理介面或gcloud](https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-autoscaler)建立具有Autoscaler的節點池(node pool)，讓其自動擴展。

## Reference
 - [Google Cloud Managed Service for Prometheus](https://cloud.google.com/stackdriver/docs/managed-prometheus)
 - [HPA](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)
 - [VPA](https://github.com/kubernetes/autoscaler/tree/master/vertical-pod-autoscaler)
 - [VPA in GKE](https://cloud.google.com/kubernetes-engine/docs/concepts/verticalpodautoscaler)
 - [How GKE collects GPU metrics(DCGM)](https://cloud.google.com/kubernetes-engine/docs/how-to/dcgm-metrics)
 - [this page's source code](http://192.168.201.83:8088/zoo/devops/-/tree/main/snippets/gke-autoscale)