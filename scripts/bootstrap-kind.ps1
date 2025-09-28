# Bootstrap a local kind cluster and install ArgoCD + Helm charts (Windows PowerShell)
Write-Host "This script bootstraps a local kind cluster for testing. Ensure Docker and kind are installed."

# Example commands (commented)
# kind create cluster --name demo
# helm repo add argo https://argoproj.github.io/argo-helm
# helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
# helm repo update
# helm install argocd argo/argo-cd --namespace argocd --create-namespace
# helm install prometheus prometheus-community/prometheus --namespace monitoring --create-namespace
