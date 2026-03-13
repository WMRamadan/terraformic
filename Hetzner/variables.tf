variable "hcloud_token" {
  description = "Hetzner Cloud API token"
  type        = string
  sensitive   = true
}

variable "project_name" {
  description = "Prefix for all resources"
  type        = string
  default     = "k3s-ha"
}

variable "location" {
  description = "Hetzner location"
  type        = string
  default     = "hel1"
}

variable "server_count" {
  description = "Number of k3s server nodes (control-plane + worker)"
  type        = number
  default     = 3
}

variable "server_type" {
  description = "Hetzner server type for k3s nodes"
  type        = string
  default     = "cpx31"
}

variable "image" {
  description = "Hetzner image name (Ubuntu 24.04 default)"
  type        = string
  default     = "ubuntu-24.04"
}

variable "ssh_public_key_path" {
  description = "Path to public SSH key"
  type        = string
}

variable "k3s_version" {
  description = "k3s version (e.g., v1.30.5+k3s1). Leave empty for latest."
  type        = string
  default     = ""
}

variable "pod_cidr" {
  description = "Pod CIDR"
  type        = string
  default     = "10.244.0.0/16"
}

variable "service_cidr" {
  description = "Service CIDR"
  type        = string
  default     = "10.96.0.0/12"
}

variable "longhorn_version" {
  description = "Longhorn Helm chart version (optional)"
  type        = string
  default     = ""
}

variable "lb_type" {
  description = "Hetzner load balancer type"
  type        = string
  default     = "lb11"
}

variable "enable_public_ssh" {
  description = "Allow SSH from the public internet to k3s nodes"
  type        = bool
  default     = false
}

variable "ssh_allowed_cidrs" {
  description = "CIDRs allowed to SSH into the bastion"
  type        = list(string)
  default     = ["62.65.58.64/32"]
}

variable "bastion_server_type" {
  description = "Hetzner server type for bastion"
  type        = string
  default     = "ccx1"
}
