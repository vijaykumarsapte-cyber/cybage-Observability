#!/usr/bin/env bash
# Browser access to Prometheus and Alertmanager through the Application Gateway.
# Runs inside the cluster via `az aks command invoke` (the AKS API is private),
# with these files uploaded next to it:
#   obs-auth-proxy.yaml, obs-ui-ingress.yaml
#   htpasswd (optional) - one line "user:<sha512-crypt hash>"; never the plain
#                         password. When absent, the existing secret is kept.
set -euo pipefail
NS=monitoring

# Public IP of the gateway, read from the existing application ingress.
APPGW_IP=$(kubectl get ingress demo-ingress -n default -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
[ -n "$APPGW_IP" ] || { echo "ERROR: could not read the gateway IP from demo-ingress"; exit 1; }
echo "Application Gateway IP: $APPGW_IP"

# 1. TLS: self-signed certificate for the gateway IP. Created once and kept;
#    the private key is generated here and never leaves the cluster/gateway.
#    Valid 365 days - delete the secret and rerun to renew.
if ! kubectl get secret obs-ui-tls -n "$NS" >/dev/null 2>&1; then
  echo "Creating self-signed TLS secret obs-ui-tls for $APPGW_IP"
  openssl req -x509 -newkey rsa:2048 -sha256 -days 365 -nodes \
    -keyout tls.key -out tls.crt -subj "/CN=$APPGW_IP" \
    -addext "subjectAltName=IP:$APPGW_IP" 2>/dev/null
  kubectl create secret tls obs-ui-tls -n "$NS" --cert=tls.crt --key=tls.key
  rm -f tls.key tls.crt
else
  echo "TLS secret obs-ui-tls exists - kept"
fi

# 2. Basic-auth users.
if [ -f htpasswd ]; then
  echo "Updating secret obs-ui-basic-auth"
  kubectl create secret generic obs-ui-basic-auth -n "$NS" --from-file=auth=htpasswd \
    --dry-run=client -o yaml | kubectl apply -f -
  rm -f htpasswd
elif ! kubectl get secret obs-ui-basic-auth -n "$NS" >/dev/null 2>&1; then
  echo "ERROR: secret obs-ui-basic-auth is missing; set the OBS_UI_PASSWORD pipeline secret variable"
  exit 1
else
  echo "Secret obs-ui-basic-auth exists - kept"
fi

# 3. Proxy, then the ingress. nginx reads the conf only at start, so restart
#    the proxy when its ConfigMap changed (the htpasswd file is read per request).
out=$(kubectl apply -f obs-auth-proxy.yaml)
echo "$out"
if echo "$out" | grep -q 'configmap/obs-auth-proxy-config configured'; then
  kubectl rollout restart deployment/obs-auth-proxy -n "$NS"
fi
kubectl rollout status deployment/obs-auth-proxy -n "$NS" --timeout=180s
kubectl apply -f obs-ui-ingress.yaml

kubectl get ingress -A
