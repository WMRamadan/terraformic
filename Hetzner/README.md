# Hetzner HA k3s

Terraform setup to create a 3-node k3s HA cluster on Hetzner Cloud. Each node is both control-plane and worker, and the Hetzner LB load-balances the API.

This deployment bootstraps the cluster via cloud-init only (no SSH to nodes). A bastion host is provisioned for SSH access to the private nodes.

## Prereqs
- Terraform >= 1.5
- Hetzner Cloud API token
- SSH public key (uploaded to servers)

## Backend state
Edit `Hetzner/backend.tf` and replace `REPLACE_ME_*` values before running `terraform init`.

## Usage
1. Create a `terraform.tfvars` with your settings.
2. Run `terraform init && terraform apply`.

Example `terraform.tfvars`:
```hcl
hcloud_token        = "YOUR_TOKEN"
ssh_public_key_path = "/path/to/id_ed25519.pub"
project_name        = "k3s-ha"
location            = "fsn1"
ssh_allowed_cidrs   = ["62.65.58.64/32"]
```

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
