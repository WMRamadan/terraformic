variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "cluster_version" {
  type = string
}

variable "cluster_endpoint_private_access" {
  type = bool
}

variable "cluster_endpoint_public_access" {
  type = bool
}

variable "cluster_endpoint_public_access_cidrs" {
  type = list(string)
}

variable "enabled_cluster_log_types" {
  type = list(string)
}

variable "cluster_log_retention_days" {
  type = number
}

variable "node_instance_type" {
  type = string
}

variable "node_per_az" {
  type = number
}

variable "node_min_per_az" {
  type = number
}

variable "node_max_per_az" {
  type = number
}

variable "key_name" {
  type    = string
  default = null
}

variable "enable_public_ssh" {
  type = bool
}

variable "ssh_allowed_cidrs" {
  type = list(string)
}

variable "vpc_cidr" {
  type = string
}

variable "enable_efs" {
  type = bool
}
