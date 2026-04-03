variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "project_name" {
  description = "Prefix for all resources"
  type        = string
  default     = "k8s-eks"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs (for NAT/LB)"
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs (for EKS nodes)"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
}

variable "nat_gateway_per_az" {
  description = "Create one NAT Gateway per AZ for HA"
  type        = bool
  default     = true
}

variable "cluster_version" {
  description = "EKS Kubernetes version"
  type        = string
  default     = "1.30"
}

variable "cluster_endpoint_private_access" {
  description = "Enable private endpoint access for EKS API"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access" {
  description = "Enable public endpoint access for EKS API"
  type        = bool
  default     = false
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "Allowed CIDRs for EKS public endpoint when enabled"
  type        = list(string)
  default     = []
}

variable "enabled_cluster_log_types" {
  description = "EKS control plane logs to enable"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "cluster_log_retention_days" {
  description = "CloudWatch log retention for EKS control plane logs"
  type        = number
  default     = 30
}

variable "node_instance_type" {
  description = "EC2 instance type for worker nodes"
  type        = string
  default     = "t3.large"
}

variable "node_per_az" {
  description = "Desired worker nodes per AZ"
  type        = number
  default     = 1
}

variable "node_min_per_az" {
  description = "Minimum worker nodes per AZ"
  type        = number
  default     = 1
}

variable "node_max_per_az" {
  description = "Maximum worker nodes per AZ"
  type        = number
  default     = 3
}

variable "ssh_public_key_path" {
  description = "Path to public SSH key (only used when public SSH is enabled)"
  type        = string
  default     = ""
}

variable "ssh_key_name" {
  description = "Name for the AWS key pair"
  type        = string
  default     = "k8s-eks-key"
}

variable "enable_public_ssh" {
  description = "Allow SSH to worker nodes"
  type        = bool
  default     = false
}

variable "ssh_allowed_cidrs" {
  description = "CIDRs allowed to SSH into nodes when public SSH is enabled"
  type        = list(string)
  default     = []
}

variable "enable_efs" {
  description = "Provision EFS and install the EFS CSI driver"
  type        = bool
  default     = true
}

variable "manage_kubernetes_resources" {
  description = "Create in-cluster resources via Terraform kubernetes provider"
  type        = bool
  default     = false
}
