#!/bin/bash

set -e

MONITORING_NS="monitoring"
LOGGING_NS="logging"

echo "=================================================="
echo "EMS Observability Stack Deployment"
echo "=================================================="

#
# Verify AKS Connectivity
#
echo ""
echo "Validating AKS Cluster Connectivity..."

kubectl get nodes > /dev/null

echo "AKS connection successful."

#
# Create Namespaces
#
echo ""
echo "Creating Namespaces..."

kubectl create namespace "$MONITORING_NS" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create namespace "$LOGGING_NS" \
  --dry-run=client -o yaml | kubectl apply -f -

#
# Add Helm Repositories
#
echo ""
echo "Adding Helm repositories..."

helm repo add prometheus-community \
  https://prometheus-community.github.io/helm-charts || true

helm repo add grafana \
  https://grafana.github.io/helm-charts || true

helm repo update

#
# Create kube-prometheus-stack values
#
echo ""
echo "Creating monitoring configuration..."

cat <<'EOF' > /tmp/monitoring-values.yaml

# ==================================================
# Grafana
# ==================================================

grafana:
  enabled: true

  adminUser: admin
  adminPassword: "EMS@Grafana123"

  service:
    type: LoadBalancer

  persistence:
    enabled: false

  resources: {}
  
  # Automatically configure Loki as a datasource
  additionalDataSources:
    - name: Loki
      type: loki
      access: proxy
      url: http://loki.logging.svc.cluster.local:3100
      isDefault: false
      editable: true

# ==================================================
# Prometheus
# ==================================================

prometheus:
  enabled: true

  service:
    type: LoadBalancer

  prometheusSpec:

    retention: 7d

    # Important for small/single-node AKS clusters
    resources: {}

    # Discover Kubernetes services/pods
    serviceMonitorSelectorNilUsesHelmValues: false

# ==================================================
# Alertmanager
# ==================================================

alertmanager:
  enabled: true

  service:
    type: LoadBalancer

  alertmanagerSpec:
    resources: {}

# ==================================================
# Node Exporter
# ==================================================

nodeExporter:
  enabled: true

  resources: {}

# ==================================================
# Kube State Metrics
# ==================================================

kubeStateMetrics:
  enabled: true

# ==================================================
# Prometheus Operator
# ==================================================

prometheusOperator:
  enabled: true

  resources: {}

EOF

echo "Monitoring configuration created:"
echo "/tmp/monitoring-values.yaml"

#
# Deploy kube-prometheus-stack
#
echo ""
echo "Deploying kube-prometheus-stack..."

helm upgrade --install monitoring \
  prometheus-community/kube-prometheus-stack \
  -n "$MONITORING_NS" \
  -f /tmp/monitoring-values.yaml

#
# Deploy Loki
#
echo ""
echo "Deploying Loki..."

cat <<'EOF' > /tmp/loki-values.yaml

deploymentMode: SingleBinary

singleBinary:
  replicas: 1

loki:
  auth_enabled: false

  commonConfig:
    replication_factor: 1

  storage:
    type: filesystem

  schemaConfig:
    configs:
      - from: "2024-01-01"
        store: tsdb
        object_store: filesystem
        schema: v13
        index:
          prefix: loki_index_
          period: 24h

backend:
  replicas: 0

read:
  replicas: 0

write:
  replicas: 0

EOF

helm upgrade --install loki \
  grafana/loki \
  -n "$LOGGING_NS" \
  -f /tmp/loki-values.yaml

#
# Create Alloy Configuration
#
echo ""
echo "Creating Alloy configuration..."

cat <<'EOF' > /tmp/alloy-values.yaml

controller:
  type: daemonset

alloy:
  mounts:
    varlog: true

  configMap:
    create: true
    content: |
      discovery.kubernetes "pods" {
        role = "pod"
      }

      loki.source.kubernetes "pods" {
        targets    = discovery.kubernetes.pods.targets
        forward_to = [loki.write.default.receiver]
      }

      loki.write "default" {
        endpoint {
          url = "http://loki.logging.svc.cluster.local:3100/loki/api/v1/push"
        }
      }

EOF

#
# Deploy Alloy
#
echo ""
echo "Deploying Alloy..."

helm upgrade --install alloy \
  grafana/alloy \
  -n "$LOGGING_NS" \
  -f /tmp/alloy-values.yaml

#
# Wait for Components
#
echo ""
echo "Waiting for components to initialize..."

sleep 60

#
# Verify Alloy
#
echo ""
echo "=================================================="
echo "ALLOY VALIDATION"
echo "=================================================="

kubectl get daemonset -n "$LOGGING_NS" || true

kubectl get pods -n "$LOGGING_NS"

echo ""
echo "Alloy log collection configured for Kubernetes pods."

#
# Verify Loki
#
echo ""
echo "=================================================="
echo "LOKI VALIDATION"
echo "=================================================="

kubectl get svc -n "$LOGGING_NS"

echo ""
echo "Loki Endpoint:"
echo "http://loki.logging.svc.cluster.local:3100"

#
# Monitoring Validation
#
echo ""
echo "=================================================="
echo "MONITORING PODS"
echo "=================================================="

kubectl get pods -n "$MONITORING_NS"

#
# Logging Validation
#
echo ""
echo "=================================================="
echo "LOGGING PODS"
echo "=================================================="

kubectl get pods -n "$LOGGING_NS"

#
# Application Validation
#
echo ""
echo "=================================================="
echo "EMS APPLICATION PODS"
echo "=================================================="

kubectl get pods -n default

#
# Services Validation
#
echo ""
echo "=================================================="
echo "MONITORING SERVICES"
echo "=================================================="

kubectl get svc -n "$MONITORING_NS"

echo ""
echo "=================================================="
echo "LOGGING SERVICES"
echo "=================================================="

kubectl get svc -n "$LOGGING_NS"

#
# Capture External URLs
#
echo ""
echo "=================================================="
echo "ACCESS DETAILS"
echo "=================================================="

GRAFANA_IP=$(kubectl get svc monitoring-grafana \
  -n "$MONITORING_NS" \
  -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || true)

PROM_IP=$(kubectl get svc monitoring-kube-prometheus-prometheus \
  -n "$MONITORING_NS" \
  -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || true)

ALERT_IP=$(kubectl get svc monitoring-kube-prometheus-alertmanager \
  -n "$MONITORING_NS" \
  -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || true)

echo ""
echo "Grafana Username : admin"
echo "Grafana Password : EMS@Grafana123"

echo ""

if [ -n "$GRAFANA_IP" ]; then
  echo "Grafana URL      : http://$GRAFANA_IP"
else
  echo "Grafana LoadBalancer IP Pending..."
fi

if [ -n "$PROM_IP" ]; then
  echo "Prometheus URL   : http://$PROM_IP:9090"
else
  echo "Prometheus LoadBalancer IP Pending..."
fi

if [ -n "$ALERT_IP" ]; then
  echo "Alertmanager URL : http://$ALERT_IP:9093"
else
  echo "Alertmanager LoadBalancer IP Pending..."
fi

#
# Datasource Verification
#
echo ""
echo "=================================================="
echo "DATASOURCE ENDPOINTS"
echo "=================================================="

echo "Prometheus:"
echo "http://monitoring-kube-prometheus-prometheus.monitoring.svc.cluster.local:9090"

echo ""
echo "Alertmanager:"
echo "http://monitoring-kube-prometheus-alertmanager.monitoring.svc.cluster.local:9093"

echo ""
echo "Loki:"
echo "http://loki.logging.svc.cluster.local:3100"

#
# Verify EMS Apps
#
echo ""
echo "=================================================="
echo "EMS APPLICATION SERVICES"
echo "=================================================="

kubectl get svc -n default

#
# Completed
#
echo ""
echo "=================================================="
echo "Observability Stack Deployment Completed"
echo "=================================================="

echo ""
echo "Installed Components:"
echo "  ✓ Grafana"
echo "  ✓ Prometheus"
echo "  ✓ Alertmanager"
echo "  ✓ Loki"
echo "  ✓ Alloy"

echo ""
echo "Verified:"
echo "  ✓ Monitoring Namespace"
echo "  ✓ Logging Namespace"
echo "  ✓ EMS Application Pods"
echo "  ✓ Grafana Service"
echo "  ✓ Prometheus Service"
echo "  ✓ Alertmanager Service"
