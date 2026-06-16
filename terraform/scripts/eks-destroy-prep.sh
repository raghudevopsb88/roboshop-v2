#!/usr/bin/env bash
# Uninstall Helm releases while the EKS API is still reachable, then drop them
# from Terraform state so destroy does not call the Helm provider against a dead cluster.
set -uo pipefail

CLUSTER_NAME="${1:?usage: $0 <cluster-name> <aws-region>}"
AWS_REGION="${2:?usage: $0 <cluster-name> <aws-region>}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TF_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${TF_DIR}"

echo "=== EKS destroy prep: cluster=${CLUSTER_NAME} region=${AWS_REGION} ==="

if aws eks describe-cluster --name "${CLUSTER_NAME}" --region "${AWS_REGION}" >/dev/null 2>&1; then
  echo "Updating kubeconfig..."
  aws eks update-kubeconfig --name "${CLUSTER_NAME}" --region "${AWS_REGION}"

  uninstall() {
    local release="$1"
    local namespace="${2:-default}"
    echo "  helm uninstall ${release} -n ${namespace}"
    helm uninstall "${release}" -n "${namespace}" --wait --timeout 5m 2>/dev/null \
      || helm uninstall "${release}" -n "${namespace}" 2>/dev/null \
      || true
  }

  echo "Removing Istio add-ons (Kiali, Prometheus, Grafana)..."
  kubectl delete ingress kiali -n istio-system --ignore-not-found 2>/dev/null || true
  kubectl delete -f "https://raw.githubusercontent.com/istio/istio/release-1.30/samples/addons/kiali.yaml" --ignore-not-found 2>/dev/null || true
  kubectl delete -f "https://raw.githubusercontent.com/istio/istio/release-1.30/samples/addons/prometheus.yaml" --ignore-not-found 2>/dev/null || true
  kubectl delete -f "https://raw.githubusercontent.com/istio/istio/release-1.30/samples/addons/grafana.yaml" --ignore-not-found 2>/dev/null || true

  echo "Uninstalling Helm releases (reverse install order)..."
  uninstall istiod istio-system
  uninstall istio-base istio-system
  uninstall kube-prometheus-stack monitoring
  uninstall argocd argocd
  uninstall external-dns external-dns
  uninstall cluster-autoscaler kube-system
  uninstall filebeat default
  uninstall traefik traefik
  uninstall metrics-server kube-system

  echo "Deleting remaining LoadBalancer services (releases orphaned NLBs)..."
  if command -v jq >/dev/null 2>&1; then
    kubectl get svc -A -o json 2>/dev/null \
      | jq -r '.items[] | select(.spec.type=="LoadBalancer") | "\(.metadata.namespace) \(.metadata.name)"' \
      | while read -r ns name; do
          echo "  kubectl delete svc ${name} -n ${ns}"
          kubectl delete svc "${name}" -n "${ns}" --wait=false 2>/dev/null || true
        done
  else
    kubectl get svc -A 2>/dev/null | awk '$3=="LoadBalancer" {print $1, $2}' | while read -r ns name; do
      kubectl delete svc "${name}" -n "${ns}" --wait=false 2>/dev/null || true
    done
  fi

  echo "Waiting for NLBs to finish deleting..."
  sleep 45
else
  echo "Cluster ${CLUSTER_NAME} not found — skipping live helm uninstall."
fi

echo "Removing module.eks.helm_release.* from Terraform state..."
if terraform state list 2>/dev/null | grep -q 'module\.eks\.helm_release\.'; then
  terraform state list 2>/dev/null | grep 'module\.eks\.helm_release\.' | while read -r addr; do
    echo "  terraform state rm ${addr}"
    terraform state rm "${addr}" || true
  done
else
  echo "  (no helm_release resources in state)"
fi

echo "=== EKS destroy prep complete ==="
