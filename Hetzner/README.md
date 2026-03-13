# Hetzner HA k3s

Terraform setup to create a 3-node k3s HA cluster on Hetzner Cloud. Each node is both control-plane and worker, and the Hetzner LB load-balances the API.

This deployment bootstraps the cluster via cloud-init only (no SSH to nodes). A bastion host is provisioned for SSH access to the private nodes.

## Prereqs
- Terraform >= 1.5
- Hetzner Cloud API token
- SSH public key (uploaded to servers)
- S3-compatible bucket for Terraform state (AWS S3, Hetzner Object Storage, MinIO, etc.)

## Backend state
Terraform backends cannot read `terraform.tfvars`. Use `-backend-config` on init.

If you are using Hetzner Object Storage, export S3-compatible credentials:
```bash
export AWS_ACCESS_KEY_ID="YOUR_HETZNER_ACCESS_KEY"
export AWS_SECRET_ACCESS_KEY="YOUR_HETZNER_SECRET_KEY"
export AWS_DEFAULT_REGION="eu-central"
```

## Usage
1. Create a `terraform.tfvars` with your settings.

Example `terraform.tfvars`:
```hcl
hcloud_token        = "YOUR_TOKEN"
ssh_public_key_path = "/path/to/id_ed25519.pub"
project_name        = "k3s-ha"
location            = "hel1"
ssh_allowed_cidrs   = ["x.x.x.x/32"]
```
2. Run `terraform init` (see below).

Then init:
```bash
terraform init \
  -backend-config="bucket=REPLACE_ME" \
  -backend-config="key=hetzner/terraform.tfstate" \
  -backend-config="region=REPLACE_ME" \
  -backend-config="endpoint=REPLACE_ME"
```

2. Run `terraform plan` to see the plan and `terraform apply` to apply the plan.

## Access via bastion
1. SSH into bastion:
```bash
ssh root@<bastion_public_ip>
```

2. From bastion, `kubectl` is installed and kubeconfig is pulled from the first node:
```bash
kubectl get nodes
```

## Outputs
- Load balancer public IP
- Server public IPs
- Bastion public/private IPs

## Notes
- k3s version is configurable via `k3s_version` (default: latest).
- Ubuntu image is configurable via `image` (default `ubuntu-24.04`).
- Longhorn chart version is optional via `longhorn_version`.
