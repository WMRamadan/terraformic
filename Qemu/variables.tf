variable "qemu_host" {
  description = "KVM/QEMU host IP or DNS name"
  type        = string
}

variable "qemu_user" {
  description = "SSH username for remote QEMU host"
  type        = string
}

variable "qemu_ssh_private_key_path" {
  description = "Path to SSH private key used to connect to QEMU host"
  type        = string
}

variable "project_name" {
  description = "Prefix for VM and network resources"
  type        = string
  default     = "k3s-qemu"
}

variable "libvirt_pool_name" {
  description = "Libvirt storage pool name"
  type        = string
  default     = "k3s-pool"
}

variable "libvirt_pool_path" {
  description = "Directory path on QEMU host for VM disks"
  type        = string
  default     = "/var/lib/libvirt/images/k3s-qemu"
}

variable "network_name" {
  description = "Libvirt network name"
  type        = string
  default     = "k3s-net"
}

variable "network_domain" {
  description = "Libvirt network DNS domain"
  type        = string
  default     = "k3s.local"
}

variable "network_cidr" {
  description = "CIDR for libvirt NAT network"
  type        = string
  default     = "10.42.0.0/24"
}

variable "haproxy_ip" {
  description = "Static IP for HAProxy VM"
  type        = string
  default     = "10.42.0.10"
}

variable "k3s_node_ips" {
  description = "Static IPs for 3 k3s server nodes (control-plane + worker)"
  type        = list(string)
  default     = ["10.42.0.11", "10.42.0.12", "10.42.0.13"]
}

variable "ubuntu_image_url" {
  description = "Ubuntu cloud image URL"
  type        = string
  default     = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
}

variable "haproxy_memory_mb" {
  description = "RAM for HAProxy VM"
  type        = number
  default     = 1024
}

variable "haproxy_vcpu" {
  description = "vCPU for HAProxy VM"
  type        = number
  default     = 1
}

variable "k3s_node_memory_mb" {
  description = "RAM for each k3s node VM"
  type        = number
  default     = 4096
}

variable "k3s_node_vcpu" {
  description = "vCPU for each k3s node VM"
  type        = number
  default     = 2
}

variable "vm_disk_size_bytes" {
  description = "Disk size for each VM"
  type        = number
  default     = 53687091200
}

variable "ssh_username" {
  description = "Username created by cloud-init"
  type        = string
  default     = "kube"
}

variable "ssh_password" {
  description = "Password for ssh_username"
  type        = string
  sensitive   = true
}

variable "ssh_authorized_key" {
  description = "Optional SSH public key content for ssh_username"
  type        = string
  default     = ""
}

variable "k3s_token" {
  description = "Shared K3s cluster token"
  type        = string
  sensitive   = true
}

variable "k3s_version" {
  description = "K3s version"
  type        = string
  default     = "v1.34.5+k3s1"
}

variable "k3s_cluster_cidr" {
  description = "Pod CIDR"
  type        = string
  default     = "10.244.0.0/16"
}

variable "k3s_service_cidr" {
  description = "Service CIDR"
  type        = string
  default     = "10.96.0.0/12"
}
