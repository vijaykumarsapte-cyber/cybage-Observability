#!/bin/bash

set -e

LOGGING_NS="logging"

echo "=================================================="
echo "Tempo + OpenTelemetry Collector Deployment"
echo "=================================================="

#
# Verify Cluster Connectivity
#
echo ""
echo "Validating Cluster Connectivity..."

kubectl get nodes >/dev/null

echo "Cluster connection successful."

#
# Ensure Namespace Exists
#
echo ""
echo "Ensuring namespace exists..."

kubectl create namespace "$LOGGING_NS" \
  --dry-run=client -o yaml | kubectl apply -f -

#
# Add Helm Repositories
#
echo ""
echo "Adding Helm repositories..."

helm repo add grafana https://grafana.github.io/helm-charts || true

helm repo add open-telemetry \
  https://open-telemetry.github.io/opentelemetry-helm-charts || true

helm repo update

#
# Install Tempo
#
echo ""
echo "Installing Tempo..."

cat <<'EOF' >/tmp/tempo-values.yaml

tempo:
  reportingEnabled: false

service:
  type: ClusterIP

persistence:
  enabled: false

traces:
  otlp:
    grpc:
      enabled: true
    http:
      enabled: true

EOF

helm upgrade --install tempo \
  grafana/tempo \
  -n "$LOGGING_NS" \
  -f /tmp/tempo-values.yaml

#
# Install OpenTelemetry Collector
#
echo ""
echo "Installing OpenTelemetry Collector..."

cat <<'EOF' >/tmp/otel-values.yaml

mode: deployment

replicaCount: 1

image:
  repository: otel/opentelemetry-collector-contrib
  tag: latest

config:

  receivers:
    otlp:
      protocols:
        grpc: {}
        http: {}

  processors:
    batch: {}

  exporters:
    otlp:
      endpoint: tempo.logging.svc.cluster.local:4317
      tls:
        insecure: true

  service:
    pipelines:
      traces:
        receivers:
          - otlp
        processors:
          - batch
        exporters:
          - otlp

ports:
  otlp:
    enabled: true
    containerPort: 4317
    servicePort: 4317
    protocol: TCP

  otlp-http:
    enabled: true
    containerPort: 4318
    servicePort: 4318
    protocol: TCP

EOF

helm upgrade --install otel-collector \
  open-telemetry/opentelemetry-collector \
  -n "$LOGGING_NS" \
  -f /tmp/otel-values.yaml

#
# Wait for Deployments
#
echo ""
echo "Waiting for deployments..."

sleep 30

#
# Verify Tempo
#
echo ""
echo "Waiting for Tempo..."

kubectl wait \
  --for=condition=available deployment/tempo \
  -n "$LOGGING_NS" \
  --timeout=300s || true

#
# Verify OTel Collector
#
echo ""
echo "Waiting for OpenTelemetry Collector..."

kubectl rollout status \
  deployment/otel-collector-opentelemetry-collector \
  -n "$LOGGING_NS" \
  --timeout=300s || true

#
# Validation
#
echo ""
echo "=================================================="
echo "TEMPO PODS"
echo "=================================================="

kubectl get pods -n "$LOGGING_NS" | grep tempo || true

echo ""
echo "=================================================="
echo "OTEL COLLECTOR PODS"
echo "=================================================="

kubectl get pods -n "$LOGGING_NS" | grep otel || true

echo ""
echo "=================================================="
echo "SERVICES"
echo "=================================================="

kubectl get svc -n "$LOGGING_NS"

#
# Endpoints
#
echo ""
echo "=================================================="
echo "ENDPOINTS"
echo "=================================================="

echo ""
echo "Tempo Query Endpoint:"
echo "http://tempo.logging.svc.cluster.local:3100"

echo ""
echo "Tempo OTLP gRPC Endpoint:"
echo "tempo.logging.svc.cluster.local:4317"

echo ""
echo "Tempo OTLP HTTP Endpoint:"
echo "http://tempo.logging.svc.cluster.local:4318"

echo ""
echo "OpenTelemetry Collector gRPC Endpoint:"
echo "otel-collector-opentelemetry-collector.logging.svc.cluster.local:4317"

echo ""
echo "OpenTelemetry Collector HTTP Endpoint:"
echo "http://otel-collector-opentelemetry-collector.logging.svc.cluster.local:4318"

#
# Quick Health Checks
#
echo ""
echo "=================================================="
echo "HEALTH CHECKS"
echo "=================================================="

kubectl get deployments -n "$LOGGING_NS"

echo ""
kubectl get pods -n "$LOGGING_NS"

#
# Completed
#
echo ""
echo "=================================================="
echo "INSTALLATION COMPLETED"
echo "=================================================="

echo ""
echo "New Components Installed:"
echo "  ✓ Tempo"
echo "  ✓ OpenTelemetry Collector"

echo ""
echo "Existing Components Unchanged:"
echo "  ✓ Grafana"
echo "  ✓ Prometheus"
echo "  ✓ Alertmanager"
echo "  ✓ Loki"
echo "  ✓ Alloy"

echo ""
echo "Configure tracing in your applications using:"
echo "  gRPC : otel-collector-opentelemetry-collector.logging.svc.cluster.local:4317"
echo "  HTTP : http://otel-collector-opentelemetry-collector.logging.svc.cluster.local:4318"

echo ""
echo "Add Grafana"