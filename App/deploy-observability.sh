#!/usr/bin/env bash

set -euo pipefail

# ============================================================
# EMS Observability Stack Deployment
# Environment:
#   Private AKS
#   Azure Application Gateway
#   AGIC
#
# Important:
#   - Does NOT install NGINX ingress
#   - Does NOT modify EMS application ingress
#   - Grafana, Prometheus, Alertmanager and Loki use ClusterIP
#   - Intended to run through:
#       az aks command invoke
# ============================================================


# ============================================================
# Configuration
# ============================================================

MONITORING_NS="monitoring"
LOGGING_NS="logging"

MONITORING_RELEASE="monitoring"
LOKI_RELEASE="loki"
ALLOY_RELEASE="alloy"

# Browser URL of the Application Gateway. Prometheus and Alertmanager are served
# at ${OBS_PUBLIC_URL}/prometheus and /alertmanager through obs-auth-proxy
# (k8/obs-auth-proxy.yaml, k8/obs-ui-ingress.yaml). The IP is read from the
# application ingress; the fallback is the gateway IP at the time of writing.
APPGW_IP=$(kubectl get ingress demo-ingress -n default \
  -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || true)
OBS_PUBLIC_URL="https://${APPGW_IP:-20.204.148.12}"

# ============================================================
# Grafana Credentials
# Hardcoded as requested
# ============================================================

GRAFANA_ADMIN_USER="admin"
GRAFANA_ADMIN_PASSWORD="EMS@Grafana123"


echo "=================================================="
echo "EMS OBSERVABILITY STACK DEPLOYMENT"
echo "=================================================="
echo ""
echo "Monitoring Namespace : ${MONITORING_NS}"
echo "Logging Namespace    : ${LOGGING_NS}"
echo ""
echo "NGINX Ingress        : NOT USED"
echo "Service Exposure     : ClusterIP"
echo ""
echo "=================================================="


# ============================================================
# Validate AKS Connectivity
# ============================================================

echo ""
echo "=================================================="
echo "AKS CONNECTIVITY VALIDATION"
echo "=================================================="
echo ""

echo "Checking AKS connectivity..."

kubectl get nodes

echo ""
echo "AKS connectivity validated successfully."

echo ""
echo "AKS Nodes:"
kubectl get nodes -o wide


# ============================================================
# Verify Required Commands
# ============================================================

echo ""
echo "=================================================="
echo "TOOL VALIDATION"
echo "=================================================="

echo ""
echo "Checking kubectl..."

kubectl version --client

echo ""
echo "Checking Helm..."

helm version

echo ""
echo "kubectl and Helm are available."


# ============================================================
# Validate Existing Ingress Classes
# ============================================================

echo ""
echo "=================================================="
echo "INGRESS CLASS VALIDATION"
echo "=================================================="
echo ""

kubectl get ingressclass || true

echo ""
echo "Checking Azure Application Gateway Ingress Class..."

if kubectl get ingressclass azure-application-gateway \
  >/dev/null 2>&1; then

    echo "OK: azure-application-gateway IngressClass found."

else

    echo "WARNING:"
    echo "azure-application-gateway IngressClass was not found."
    echo ""
    echo "This observability deployment will continue because"
    echo "it does not create or modify application ingress."

fi


# ============================================================
# NGINX Safety Check
# ============================================================

echo ""
echo "=================================================="
echo "NGINX INGRESS SAFETY CHECK"
echo "=================================================="

echo ""
echo "Checking existing NGINX ingress resources..."

NGINX_INGRESSES=$(
  kubectl get ingress \
    -A \
    -o jsonpath='{range .items[?(@.spec.ingressClassName=="nginx")]}{.metadata.namespace}{"/"}{.metadata.name}{"\n"}{end}' \
    2>/dev/null || true
)

if [ -n "$NGINX_INGRESSES" ]; then

    echo ""
    echo "WARNING:"
    echo "Existing nginx-class Ingress resources detected:"
    echo ""
    echo "$NGINX_INGRESSES"
    echo ""
    echo "This script WILL NOT modify these resources."

else

    echo "OK: No nginx-class Ingress resources detected."

fi


echo ""
echo "Checking for NGINX ingress controller pods..."

NGINX_PODS=$(
  kubectl get pods -A 2>/dev/null |
  grep -Ei "ingress-nginx|nginx-ingress" || true
)

if [ -n "$NGINX_PODS" ]; then

    echo ""
    echo "WARNING:"
    echo "NGINX ingress controller pods detected:"
    echo ""
    echo "$NGINX_PODS"
    echo ""
    echo "This script WILL NOT use or modify NGINX."

else

    echo "OK: No NGINX ingress controller pods detected."

fi


# ============================================================
# Display Existing Application Ingress
# ============================================================

echo ""
echo "=================================================="
echo "EXISTING APPLICATION INGRESS"
echo "=================================================="

kubectl get ingress \
  -n default \
  -o wide || true


# ============================================================
# Create Namespaces
# ============================================================

echo ""
echo "=================================================="
echo "CREATING OBSERVABILITY NAMESPACES"
echo "=================================================="

kubectl create namespace "$MONITORING_NS" \
  --dry-run=client \
  -o yaml |
kubectl apply -f -

kubectl create namespace "$LOGGING_NS" \
  --dry-run=client \
  -o yaml |
kubectl apply -f -

echo ""
echo "Namespaces created/validated successfully."

kubectl get namespace \
  "$MONITORING_NS" \
  "$LOGGING_NS"


# ============================================================
# Helm Repositories
# ============================================================

echo ""
echo "=================================================="
echo "CONFIGURING HELM REPOSITORIES"
echo "=================================================="

echo ""
echo "Adding Prometheus Community repository..."

helm repo add prometheus-community \
  https://prometheus-community.github.io/helm-charts \
  --force-update

echo ""
echo "Adding Grafana repository..."

helm repo add grafana \
  https://grafana.github.io/helm-charts \
  --force-update

echo ""
echo "Updating Helm repositories..."

helm repo update

echo ""
echo "Helm repositories configured successfully."


# ============================================================
# Create Monitoring Configuration
# ============================================================

echo ""
echo "=================================================="
echo "CREATING MONITORING CONFIGURATION"
echo "=================================================="

cat > monitoring-values.yaml <<EOF

# ============================================================
# Grafana
# ============================================================

grafana:

  enabled: true

  adminUser: "${GRAFANA_ADMIN_USER}"

  adminPassword: "${GRAFANA_ADMIN_PASSWORD}"

  # Keep Grafana private.
  service:

    type: ClusterIP

    port: 80

  persistence:

    enabled: false

  resources: {}

  # ------------------------------------------------------------
  # Grafana Subpath Configuration
  # Required because App Gateway exposes Grafana as:
  # http://20.219.60.213/grafana/
  # ------------------------------------------------------------

  grafana.ini:

    server:

      root_url: "%(protocol)s://%(domain)s/grafana/"

      serve_from_sub_path: true

  # ------------------------------------------------------------
  # Datasources
  # ------------------------------------------------------------

  additionalDataSources:

    - name: Loki

      uid: loki

      type: loki

      access: proxy

      url: http://loki.logging.svc.cluster.local:3100

      isDefault: false

      editable: true

    # - name: Prometheus

    #   uid: prometheus-custom

    #   type: prometheus

    #   access: proxy

    #   url: http://monitoring-kube-prometheus-prometheus.monitoring.svc.cluster.local:9090

    #   isDefault: true

    #   editable: true

    #   jsonData:

    #     httpMethod: POST

    #     timeInterval: 30s

# ============================================================
# Prometheus
# ============================================================

prometheus:

  enabled: true

  service:

    type: ClusterIP

  prometheusSpec:

    retention: 7d

    resources: {}

    serviceMonitorSelectorNilUsesHelmValues: false

    podMonitorSelectorNilUsesHelmValues: false

    # UI links use the browser path; Prometheus itself still serves at "/"
    # (routePrefix), so in-cluster URLs and Grafana data sources are unchanged.
    externalUrl: "${OBS_PUBLIC_URL}/prometheus"

    routePrefix: /

# ============================================================
# Alertmanager
# ============================================================

alertmanager:

  enabled: true

  service:

    type: ClusterIP

  alertmanagerSpec:

    resources: {}

    externalUrl: "${OBS_PUBLIC_URL}/alertmanager"

    routePrefix: /

# ============================================================
# Node Exporter
# ============================================================

nodeExporter:

  enabled: true

# ============================================================
# Kube State Metrics
# ============================================================

kubeStateMetrics:

  enabled: true

# ============================================================
# Prometheus Operator
# ============================================================

prometheusOperator:

  enabled: true

  resources: {}

EOF

echo ""
echo "Monitoring configuration created successfully."


# ============================================================
# Deploy kube-prometheus-stack
# ============================================================

echo ""
echo "=================================================="
echo "DEPLOYING KUBE-PROMETHEUS-STACK"
echo "=================================================="

helm upgrade --install "$MONITORING_RELEASE" \
  prometheus-community/kube-prometheus-stack \
  --namespace "$MONITORING_NS" \
  --create-namespace \
  --values monitoring-values.yaml \
  --wait \
  --timeout 15m

echo ""
echo "kube-prometheus-stack deployment completed."


# ============================================================
# Create Loki Configuration
# ============================================================

echo ""
echo "=================================================="
echo "CREATING LOKI CONFIGURATION"
echo "=================================================="

cat > loki-values.yaml <<'EOF'

deploymentMode: SingleBinary

singleBinary:

  replicas: 1


# ============================================================
# Loki
# ============================================================

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


# ============================================================
# Disable Distributed Components
# ============================================================

backend:

  replicas: 0

read:

  replicas: 0

write:

  replicas: 0

# ============================================================
# Disable Cache Components
# These are causing the 9830Mi memory request
# ============================================================

chunksCache:
  enabled: false

resultsCache:
  enabled: false

# ============================================================
# Disable Cache Persistence
# ============================================================

memcached:
  enabled: false

memcachedChunks:
  enabled: false

memcachedFrontend:
  enabled: false

memcachedIndexQueries:
  enabled: false

memcachedIndexWrites:
  enabled: false

EOF

echo ""
echo "Loki configuration created successfully."


# ============================================================
# Deploy Loki
# ============================================================

echo ""
echo "=================================================="
echo "DEPLOYING LOKI"
echo "=================================================="

helm upgrade --install "$LOKI_RELEASE" \
  grafana/loki \
  --namespace "$LOGGING_NS" \
  --create-namespace \
  --values loki-values.yaml \
  --wait \
  --timeout 15m

echo ""
echo "Loki deployment completed."


# ============================================================
# Create Alloy Configuration
# ============================================================

echo ""
echo "=================================================="
echo "CREATING ALLOY CONFIGURATION"
echo "=================================================="

cat > alloy-values.yaml <<'EOF'

controller:

  type: daemonset


alloy:

  mounts:

    varlog: true

  configMap:

    create: true

    content: |

      // ======================================================
      // Discover Kubernetes Pods
      // ======================================================

      discovery.kubernetes "pods" {

        role = "pod"

      }


      // ======================================================
      // Collect Kubernetes Pod Logs
      // ======================================================

      loki.source.kubernetes "pods" {

        targets = discovery.kubernetes.pods.targets

        forward_to = [
          loki.write.default.receiver,
        ]

      }


      // ======================================================
      // Send Logs to Loki
      // ======================================================

      loki.write "default" {

        endpoint {

          url = "http://loki.logging.svc.cluster.local:3100/loki/api/v1/push"

        }

      }

EOF

echo ""
echo "Alloy configuration created successfully."



# ============================================================
# Deploy Alloy
# ============================================================

echo ""
echo "=================================================="
echo "DEPLOYING ALLOY"
echo "=================================================="

helm upgrade --install "$ALLOY_RELEASE" \
  grafana/alloy \
  --namespace "$LOGGING_NS" \
  --create-namespace \
  --values alloy-values.yaml \
  --wait \
  --timeout 10m

echo ""
echo "Alloy deployment completed."


# ============================================================
# Monitoring Pod Validation
# ============================================================

echo ""
echo "=================================================="
echo "MONITORING PODS"
echo "=================================================="

kubectl get pods \
  -n "$MONITORING_NS" \
  -o wide


# ============================================================
# Monitoring Services
# ============================================================

echo ""
echo "=================================================="
echo "MONITORING SERVICES"
echo "=================================================="

kubectl get svc \
  -n "$MONITORING_NS" \
  -o wide


# ============================================================
# Logging Pod Validation
# ============================================================

echo ""
echo "=================================================="
echo "LOGGING PODS"
echo "=================================================="

kubectl get pods \
  -n "$LOGGING_NS" \
  -o wide


# ============================================================
# Logging Services
# ============================================================

echo ""
echo "=================================================="
echo "LOGGING SERVICES"
echo "=================================================="

kubectl get svc \
  -n "$LOGGING_NS" \
  -o wide


# ============================================================
# Alloy Validation
# ============================================================

echo ""
echo "=================================================="
echo "ALLOY VALIDATION"
echo "=================================================="

kubectl get daemonset \
  -n "$LOGGING_NS" \
  -o wide

echo ""

kubectl get pods \
  -n "$LOGGING_NS" \
  -l app.kubernetes.io/name=alloy \
  -o wide || true


# ============================================================
# Loki Validation
# ============================================================

echo ""
echo "=================================================="
echo "LOKI VALIDATION"
echo "=================================================="

kubectl get svc \
  -n "$LOGGING_NS"

echo ""
echo "Loki Internal Endpoint:"
echo ""
echo "http://loki.logging.svc.cluster.local:3100"


# ============================================================
# Grafana Validation
# ============================================================

echo ""
echo "=================================================="
echo "GRAFANA VALIDATION"
echo "=================================================="

kubectl get svc monitoring-grafana \
  -n "$MONITORING_NS"

echo ""

kubectl get endpoints monitoring-grafana \
  -n "$MONITORING_NS" || true


# ============================================================
# Prometheus Validation
# ============================================================

echo ""
echo "=================================================="
echo "PROMETHEUS VALIDATION"
echo "=================================================="

kubectl get svc monitoring-kube-prometheus-prometheus \
  -n "$MONITORING_NS"

echo ""

kubectl get pods \
  -n "$MONITORING_NS" \
  -l app.kubernetes.io/name=prometheus \
  -o wide || true


# ============================================================
# Alertmanager Validation
# ============================================================

echo ""
echo "=================================================="
echo "ALERTMANAGER VALIDATION"
echo "=================================================="

kubectl get svc monitoring-kube-prometheus-alertmanager \
  -n "$MONITORING_NS"


# ============================================================
# EMS Application Validation
# ============================================================

echo ""
echo "=================================================="
echo "EMS APPLICATION VALIDATION"
echo "=================================================="

echo ""
echo "Application Pods:"

kubectl get pods \
  -n default \
  -o wide

echo ""
echo "Application Services:"

kubectl get svc \
  -n default \
  -o wide

echo ""
echo "Application Ingress:"

kubectl get ingress \
  -n default \
  -o wide || true


# ============================================================
# Validate Existing Application Uses AGIC
# ============================================================

echo ""
echo "=================================================="
echo "AGIC APPLICATION INGRESS VALIDATION"
echo "=================================================="

AGIC_INGRESSES=$(
  kubectl get ingress \
    -A \
    -o jsonpath='{range .items[?(@.spec.ingressClassName=="azure-application-gateway")]}{.metadata.namespace}{"/"}{.metadata.name}{"\n"}{end}' \
    2>/dev/null || true
)

if [ -n "$AGIC_INGRESSES" ]; then

    echo ""
    echo "AGIC managed Ingress resources:"
    echo ""
    echo "$AGIC_INGRESSES"

else

    echo ""
    echo "WARNING:"
    echo "No azure-application-gateway Ingress resources found."

fi


# ============================================================
# Validate Monitoring Service Types
# ============================================================

echo ""
echo "=================================================="
echo "SERVICE EXPOSURE VALIDATION"
echo "=================================================="

echo ""
echo "Checking monitoring services..."

kubectl get svc \
  -n "$MONITORING_NS" \
  -o wide

echo ""

MONITORING_LB_SERVICES=$(
  kubectl get svc \
    -n "$MONITORING_NS" \
    -o jsonpath='{range .items[?(@.spec.type=="LoadBalancer")]}{.metadata.name}{"\n"}{end}' \
    2>/dev/null || true
)

if [ -n "$MONITORING_LB_SERVICES" ]; then

    echo "WARNING:"
    echo "LoadBalancer services exist in monitoring:"
    echo ""
    echo "$MONITORING_LB_SERVICES"

else

    echo "OK:"
    echo "No LoadBalancer services detected in monitoring namespace."

fi


# ============================================================
# Datasource Endpoints
# ============================================================

echo ""
echo "=================================================="
echo "INTERNAL DATASOURCE ENDPOINTS"
echo "=================================================="

echo ""
echo "Grafana:"
echo "http://monitoring-grafana.monitoring.svc.cluster.local"

echo ""
echo "Prometheus:"
echo "http://monitoring-kube-prometheus-prometheus.monitoring.svc.cluster.local:9090"

echo ""
echo "Alertmanager:"
echo "http://monitoring-kube-prometheus-alertmanager.monitoring.svc.cluster.local:9093"

echo ""
echo "Loki:"
echo "http://loki.logging.svc.cluster.local:3100"


# ============================================================
# Grafana Login Information
# ============================================================

echo ""
echo "=================================================="
echo "GRAFANA LOGIN"
echo "=================================================="

echo ""
echo "Username : ${GRAFANA_ADMIN_USER}"
echo "Password : ${GRAFANA_ADMIN_PASSWORD}"

echo ""
echo "Grafana Kubernetes Service:"
echo "monitoring-grafana.monitoring.svc.cluster.local"

echo ""
echo "NOTE:"
echo "Grafana is currently private using ClusterIP."
echo "This script does NOT create a second '/' AGIC route."
echo "This prevents conflicts with the EMS application ingress."


# ============================================================
# Final NGINX Safety Validation
# ============================================================

echo ""
echo "=================================================="
echo "FINAL NGINX SAFETY VALIDATION"
echo "=================================================="

FINAL_NGINX_INGRESSES=$(
  kubectl get ingress \
    -A \
    -o jsonpath='{range .items[?(@.spec.ingressClassName=="nginx")]}{.metadata.namespace}{"/"}{.metadata.name}{"\n"}{end}' \
    2>/dev/null || true
)

if [ -n "$FINAL_NGINX_INGRESSES" ]; then

    echo ""
    echo "WARNING:"
    echo "The following nginx-class Ingress resources already exist:"
    echo ""
    echo "$FINAL_NGINX_INGRESSES"
    echo ""
    echo "This observability script did NOT create them."

else

    echo ""
    echo "OK: No nginx-class Ingress resources detected."

fi


# ============================================================
# Deployment Summary
# ============================================================

echo ""
echo "=================================================="
echo "OBSERVABILITY STACK DEPLOYMENT COMPLETED"
echo "=================================================="

echo ""
echo "Installed Components:"
echo ""
echo "  [OK] Grafana"
echo "  [OK] Prometheus"
echo "  [OK] Alertmanager"
echo "  [OK] Loki"
echo "  [OK] Alloy"
echo "  [OK] Node Exporter"
echo "  [OK] kube-state-metrics"
echo "  [OK] Prometheus Operator"

echo ""
echo "Namespaces:"
echo ""
echo "  Monitoring : ${MONITORING_NS}"
echo "  Logging    : ${LOGGING_NS}"

echo ""
echo "Service Exposure:"
echo ""
echo "  Grafana      : ClusterIP"
echo "  Prometheus   : ClusterIP"
echo "  Alertmanager : ClusterIP"
echo "  Loki         : ClusterIP"

echo ""
echo "Grafana Login:"
echo ""
echo "  Username : ${GRAFANA_ADMIN_USER}"
echo "  Password : ${GRAFANA_ADMIN_PASSWORD}"

echo ""
echo "Networking:"
echo ""
echo "  NGINX Ingress        : NOT INSTALLED"
echo "  NGINX Ingress        : NOT USED"
echo "  EMS AGIC Ingress     : NOT MODIFIED"
echo "  Application Gateway  : Existing infrastructure"

echo ""
echo "=================================================="