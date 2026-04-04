# Qemu HA K3s Cluster (3 server nodes + HAProxy)

Terraform stack for a remote KVM/QEMU host. It creates:
- 1 HAProxy VM for API load balancing
- 3 K3s server nodes that run both control-plane and workloads

Provisioning uses cloud-init and enables SSH password auth for a configured user.

## Prereqs
- Terraform >= 1.5
- Remote KVM host reachable over SSH
- Libvirt/QEMU installed on that host
- SSH key for Terraform to connect to libvirt over SSH

## How it connects to remote libvirt
Provider URI pattern:
`qemu+ssh://<qemu_user>@<qemu_host>/system?sshauth=privkey&keyfile=<private_key_path>`

## Usage
1. Create `terraform.tfvars`:

```hcl
qemu_host                 = "203.0.113.10"
qemu_user                 = "root"
qemu_ssh_private_key_path = "~/.ssh/id_ed25519"

ssh_username = "kube"
ssh_password = "ChangeMeStrongPassword!"
k3s_token    = "super-secret-cluster-token"

# Optional: add your SSH public key content
ssh_authorized_key = "ssh-ed25519 AAAA..."
```

2. Apply:

```bash
cd Qemu
terraform init
terraform apply
```

## Outputs
- HAProxy IP and Kubernetes API endpoint
- K3s node IPs
- SSH command helpers

## Notes
- K3s API is load-balanced by HAProxy on `${haproxy_ip}:6443`.
- Nodes use static IPs from `k3s_node_ips` and `haproxy_ip`.
- This stack enforces exactly 3 K3s nodes.
