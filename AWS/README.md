# AWS EKS (Production-Ready Baseline)

Terraform setup for a hardened EKS cluster in `eu-central-1` with multi-AZ worker nodes and optional EFS shared storage.

## What is hardened
- Private worker subnets across 3 AZs
- NAT gateways for outbound private subnet traffic (`nat_gateway_per_az = true` by default)
- EKS API endpoint private by default (`cluster_endpoint_private_access = true`, `cluster_endpoint_public_access = false`)
- EKS control plane logging enabled (`api`, `audit`, `authenticator`, `controllerManager`, `scheduler`)
- CloudWatch control plane log retention (`cluster_log_retention_days`)
- KMS encryption for Kubernetes secrets in etcd
- Managed EKS addons for `vpc-cni`, `kube-proxy`, `coredns`
- Node group rolling update safety (`max_unavailable = 1`)
- Public SSH disabled by default
- Optional EFS + EFS CSI via IRSA

## Prereqs
- Terraform >= 1.5
- AWS credentials configured in your environment
- If `cluster_endpoint_public_access = false`, run Terraform from a network that can reach the private EKS API endpoint (VPN/Direct Connect/bastion)
- If enabling SSH, provide `ssh_public_key_path` and `ssh_allowed_cidrs`

## Backend state
Edit `AWS/backend.tf` and replace `REPLACE_ME_*` values before running `terraform init`.

## Usage
1. Create a `terraform.tfvars` with your settings.
2. Run `terraform init && terraform apply`.

Example `terraform.tfvars`:
```hcl
region                             = "eu-central-1"
project_name                       = "k8s-eks-prod"
public_subnet_cidrs                = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs               = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
cluster_endpoint_private_access    = true
cluster_endpoint_public_access     = false
cluster_log_retention_days         = 30
node_instance_type                 = "t3.large"
node_per_az                        = 1
node_min_per_az                    = 1
node_max_per_az                    = 3
enable_public_ssh                  = false
enable_efs                         = true
manage_kubernetes_resources        = false
```

## About `manage_kubernetes_resources`
`kubernetes_storage_class.efs` is created only when:
- `enable_efs = true`
- `manage_kubernetes_resources = true`

Set `manage_kubernetes_resources = true` only when Terraform can reach the EKS API endpoint.

## Outputs
- EKS cluster name
- API endpoint
- Cluster CA data
- Node group names
- EFS file system ID (or `null` when disabled)
