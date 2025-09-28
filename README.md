# TaskForge — End-to-End MERN DevSecOps Scaffold

TaskForge is a scaffold for an end-to-end, production-oriented MERN (React, Node, MongoDB) three-tier application deployed to AWS EKS with a full DevSecOps pipeline.

Included in this scaffold:

- Terraform (AWS provider) stubs for provisioning VPC, EKS, ECR, IAM roles, ALB, and supporting resources.
- Jenkins pipeline example (`jenkins/Jenkinsfile`) implementing lint/test/build/scan/push/update-manifests stages.
- ArgoCD `Application` manifest to deploy the `manifests/` repo via GitOps.
- Helm charts for `frontend`, `backend`, and a `mongodb` StatefulSet (under `helm-charts/`).
- Minimal sample MERN app to build and test locally (under `Application-Code/`).
- Prometheus and Grafana helm-values templates under `monitoring/`.
- PowerShell helper scripts for Windows developers in `scripts/`.
- README contains next steps for bootstrapping locally and in AWS.

Next steps:
1. Review `terraform/` and populate AWS account-specific variables (region, account id, etc.).
2. Configure Jenkins credentials and ECR access in AWS.
3. Install ArgoCD in the target cluster and apply `argocd/application.yaml` to have it sync Helm releases / manifests.
4. Replace placeholder values (images, domains, secrets) and follow the security checklist in this README before production use.

See the individual directories for usage instructions and example commands.

Detailed configuration (quickstart)

1) Terraform (provisioning)

 - Edit `terraform/variables.tf` to set `aws_region`, `cluster_name`, and subnets if you want different CIDRs.
 - Initialize and plan (PowerShell):

```powershell
cd terraform
terraform init
terraform plan -var "aws_region=us-east-1"
```

 - Apply (be aware of AWS charges):

```powershell
terraform apply -var "aws_region=us-east-1" -auto-approve
```

2) Jenkins (CI)

 - The `jenkins/Jenkinsfile` is a template and expects Jenkins to have:
	 - An AWS credential (credentialId: `aws-creds`) with permissions to push to ECR.
	 - Trivy installed on the Jenkins agent (or use the Trivy container runner).
	 - yq installed for YAML edits (or adjust script to use sed)

 - Ensure Jenkins agent can run Docker or use Docker-in-Docker to build images.

3) ArgoCD and ExternalSecrets

 - Install ArgoCD into your cluster (namespace `argocd`) and apply `argocd/application.yaml` or point ArgoCD to this repo's manifests/Helm charts.
 - ExternalSecrets example is in `argocd/external-secrets-example.yaml` — configure AWS IAM for the ExternalSecrets controller to access AWS Secrets Manager via IRSA (EKS) or node IAM.

4) Helm charts & CI integration

 - The Helm charts in `helm-charts/` contain placeholders for ECR repository URLs. Replace `REPLACE_WITH_ECR_ACCOUNT_ID` or let the CI pipeline update `values.yaml` tags automatically.

Local development notes

 - This workspace expects your application source to be in `Application-Code/`.
 - To run locally using Docker Compose (builds frontend and backend from `Application-Code`):

```powershell
docker compose up -d --build
Invoke-WebRequest -UseBasicParsing http://localhost:3500/healthz
Invoke-WebRequest -UseBasicParsing http://localhost:8080
```

Security notes

 - Do NOT commit real secrets to the repository. Use ExternalSecrets or sealed-secrets / Vault.
 - Enable image scanning and disallow images that fail critical vulnerability thresholds.
 - Configure RBAC and Pod Security Admission in EKS; run containers as non-root.

If you want, I can now:
 - Fill Terraform with a tested EKS module configuration for your specific AWS account (I will need your AWS account ID and preferred region, or you can run Terraform locally using the provided files).
 - Implement a complete Jenkinsfile with working AWS/ECR authentication commands and sample credential wiring.
 - Create ArgoCD Applications that point to the Helm charts and produce example manifests/overlays for dev/prod.
 - Add ExternalSecrets + IAM IRSA example and OPA/Gatekeeper policies for admission control.

Tell me which of the above you want me to implement next and provide any required values (for sensitive values I will provide placeholders and instructions to run locally).
