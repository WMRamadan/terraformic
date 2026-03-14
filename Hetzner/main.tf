locals {
  subnet_cidr           = "10.0.0.0/24"
  internal_cidr         = "10.0.0.0/16"
  bastion_private_ip    = cidrhost(local.subnet_cidr, 6)
  first_node_private_ip = cidrhost(local.subnet_cidr, 10)
  kubectl_version       = "v1.30.0"
  joiner_count          = max(var.server_count - 1, 0)
}

data "local_file" "ssh_public_key" {
  filename = var.ssh_public_key_path
}

resource "hcloud_ssh_key" "this" {
  name       = "${var.project_name}-key"
  public_key = data.local_file.ssh_public_key.content
}

resource "random_password" "k3s_token" {
  length  = 32
  special = false
  upper   = false
}

resource "tls_private_key" "bastion" {
  algorithm = "ED25519"
}

resource "hcloud_ssh_key" "bastion" {
  name       = "${var.project_name}-bastion-key"
  public_key = tls_private_key.bastion.public_key_openssh
}

module "network" {
  source       = "./modules/hcloud-network"
  name         = "${var.project_name}-net"
  ip_range     = local.internal_cidr
  subnet_range = local.subnet_cidr
}

resource "hcloud_firewall" "bastion" {
  name = "${var.project_name}-bastion-fw"

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "22"
    source_ips = var.ssh_allowed_cidrs
  }
}

resource "hcloud_firewall" "k3s" {
  name = "${var.project_name}-k3s-fw"

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "22"
    source_ips = ["${local.bastion_private_ip}/32"]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "6443"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "10250"
    source_ips = [local.internal_cidr]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "2379-2380"
    source_ips = [local.internal_cidr]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "9345"
    source_ips = [local.internal_cidr]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "8472"
    source_ips = [local.internal_cidr]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "30000-32767"
    source_ips = ["0.0.0.0/0", "::/0"]
  }
}

module "bootstrap" {
  source             = "./modules/hcloud-servers"
  name               = var.project_name
  role               = "server"
  node_count         = 1
  name_offset        = 0
  image              = var.image
  server_type        = var.server_type
  location           = var.location
  ssh_key_ids        = [hcloud_ssh_key.this.id, hcloud_ssh_key.bastion.id]
  network_id         = module.network.network_id
  subnet_cidr        = local.subnet_cidr
  ip_offset          = 10
  user_data_template = "${path.module}/templates/cloud-init.yaml.tftpl"
  lb_ip              = module.lb.private_ip
  bootstrap_ip       = local.first_node_private_ip
  k3s_token          = random_password.k3s_token.result
  pod_cidr           = var.pod_cidr
  service_cidr       = var.service_cidr
  k3s_version        = var.k3s_version
  firewall_ids       = [hcloud_firewall.k3s.id]
  bootstrap          = true
}

module "joiners" {
  source             = "./modules/hcloud-servers"
  name               = var.project_name
  role               = "server"
  node_count         = local.joiner_count
  name_offset        = 1
  image              = var.image
  server_type        = var.server_type
  location           = var.location
  ssh_key_ids        = [hcloud_ssh_key.this.id, hcloud_ssh_key.bastion.id]
  network_id         = module.network.network_id
  subnet_cidr        = local.subnet_cidr
  ip_offset          = 11
  user_data_template = "${path.module}/templates/cloud-init.yaml.tftpl"
  lb_ip              = module.lb.private_ip
  bootstrap_ip       = local.first_node_private_ip
  k3s_token          = random_password.k3s_token.result
  pod_cidr           = var.pod_cidr
  service_cidr       = var.service_cidr
  k3s_version        = var.k3s_version
  firewall_ids       = [hcloud_firewall.k3s.id]
  bootstrap          = false

  depends_on = [module.bootstrap]
}

resource "hcloud_server" "bastion" {
  name        = "${var.project_name}-bastion"
  image       = var.image
  server_type = var.bastion_server_type
  location    = var.location
  ssh_keys    = [hcloud_ssh_key.this.id]

  user_data = templatefile("${path.module}/templates/bastion-cloud-init.yaml.tftpl", {
    target_ip            = local.first_node_private_ip
    ssh_user             = "root"
    kubectl_version      = local.kubectl_version
    api_endpoint         = local.first_node_private_ip
    bastion_priv_key_b64 = base64encode(tls_private_key.bastion.private_key_openssh)
  })

  network {
    network_id = module.network.network_id
    ip         = local.bastion_private_ip
  }

  firewall_ids = [hcloud_firewall.bastion.id]

  depends_on = [module.bootstrap, module.joiners, module.lb]
}

module "lb" {
  source      = "./modules/hcloud-lb"
  name        = "${var.project_name}-api"
  location    = var.location
  lb_type     = var.lb_type
  network_id  = module.network.network_id
  server_ids            = concat(module.bootstrap.ids, module.joiners.ids)
}
