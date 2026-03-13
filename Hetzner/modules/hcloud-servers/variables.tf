variable "name" {
  type = string
}

variable "role" {
  type = string
}

variable "count" {
  type = number
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

variable "ssh_key_id" {
  type = string
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

variable "user_data" {
  type = string
}

variable "enable_public_ssh" {
  type    = bool
  default = false
}

variable "ssh_allowed_cidrs" {
  type    = list(string)
  default = []
}

variable "internal_cidr" {
  type    = string
  default = "10.0.0.0/16"
}
