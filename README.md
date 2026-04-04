# Terraformic

Multi-cloud Terraform stacks for Kubernetes.

## Layout
- `Hetzner/` Hetzner Cloud HA kubeadm cluster
- `AWS/` AWS EKS cluster (eu-central-1)
- `GCP/` Google Cloud GKE cluster (EU region)
- `Qemu/` Remote KVM/QEMU HA k3s cluster (HAProxy + 3 server nodes)

## Backend state
Each cloud folder has a `backend.tf` with `REPLACE_ME_*` placeholders. Update those values before running `terraform init`.

## Hetzner
Quickstart:
```bash
cd Hetzner
terraform init
terraform apply
```
Outputs:
- Load balancer public IP
- Control plane / worker public IPs
- `Hetzner/kubeconfig`

## AWS (EKS)
Quickstart:
```bash
cd AWS
terraform init
terraform apply
```
Outputs:
- EKS cluster name
- API endpoint
- Cluster CA data
- Node group names
- EFS file system ID

## GCP (GKE)
Quickstart:
```bash
cd GCP
terraform init
terraform apply
```
Outputs:
- GKE cluster name
- API endpoint
- Cluster CA data
- Filestore instance name
