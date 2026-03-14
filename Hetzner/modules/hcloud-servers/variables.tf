variable "name" {
  type = string
}

variable "role" {
  type = string
}

variable "node_count" {
  type = number
}

variable "name_offset" {
  type    = number
  default = 0
}

variable "image" {
  type = string
}

variable "server_type" {
  type = string
}

variable "location" {
  type = string
}

variable "ssh_key_ids" {
  type = list(string)
}

variable "network_id" {
  type = string
}

variable "subnet_cidr" {
  type = string
}

variable "ip_offset" {
  type = number
}

variable "user_data_template" {
  type = string
}

variable "lb_ip" {
  type = string
}

variable "bootstrap_ip" {
  type = string
}

variable "k3s_token" {
  type = string
}

variable "pod_cidr" {
  type = string
}

variable "service_cidr" {
  type = string
}


variable "k3s_version" {
  type = string
}


variable "bootstrap" {
  type    = bool
  default = false
}

variable "firewall_ids" {
  type    = list(string)
  default = []
}
