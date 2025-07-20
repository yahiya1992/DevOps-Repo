# Monitoring & Logging Stack Components

## Tool Overview

| Tool       | Purpose                                                |
|------------|--------------------------------------------------------|
| Prometheus | Metrics collection (e.g., CPU, memory, app metrics)   |
| Loki       | Centralized logging backend                           |
| Grafana    | Visualization dashboard + alerting                    |

---

## 1. Installing `kube-prometheus-stack`

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace
```

This installs:

- Prometheus  
- Alertmanager  
- Grafana  
- Node Exporters  
- kube-state-metrics  

---

## 2. Installing Loki and Promtail

```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

helm upgrade --install loki grafana/loki-stack \
  --namespace monitoring
```

This deploys:

- **Loki** for log storage  
- **Promtail** as a log shipper from nodes  

---

## 3. Creating a PrometheusRule to Alert on Frequent Pod Restarts

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: app-alerts
  namespace: monitoring
spec:
  groups:
  - name: app.rules
    rules:
    - alert: HighPodRestarts
      expr: increase(kube_pod_container_status_restarts_total{namespace="default"}[5m]) > 3
      for: 1m
      labels:
        severity: critical
      annotations:
        summary: "High pod restarts in default namespace"
        description: "More than 3 restarts in 5m for pods in default"
```

---

## 4. Prometheus Helm Override

### 🔧 `prometheus-values.yaml`

```yaml
grafana:
  enabled: true
  adminPassword: "admin"
  service:
    type: LoadBalancer

prometheus:
  prometheusSpec:
    retention: 10d
    resources:
      requests:
        memory: "400Mi"
        cpu: "200m"
      limits:
        memory: "1Gi"
        cpu: "500m"
    serviceMonitorSelectorNilUsesHelmValues: false
    ruleSelectorNilUsesHelmValues: false

alertmanager:
  alertmanagerSpec:
    replicas: 1
    resources:
      requests:
        cpu: 100m
        memory: 200Mi
      limits:
        cpu: 200m
        memory: 400Mi
```

---

## 5. Loki Helm Override

### 🔧 `loki-values.yaml`

```yaml
loki:
  config:
    table_manager:
      retention_deletes_enabled: true
      retention_period: 168h  # 7 days

  resources:
    requests:
      cpu: 100m
      memory: 256Mi
    limits:
      cpu: 300m
      memory: 512Mi

promtail:
  enabled: true
  config:
    clients:
      - url: http://loki:3100/loki/api/v1/push
  resources:
    requests:
      cpu: 50m
      memory: 128Mi
    limits:
      cpu: 150m
      memory: 256Mi
```

---

> **Note**: You can override the default `values.yaml` files of the above Helm charts with your custom configuration as needed.
