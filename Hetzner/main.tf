locals {
  subnet_cidr         = "10.0.0.0/24"
  internal_cidr       = "10.0.0.0/16"
  bastion_private_ip  = cidrhost(local.subnet_cidr, 5)
  first_node_private_ip = cidrhost(local.subnet_cidr, 10)
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

resource "hcloud_server" "bastion" {
  name        = "${var.project_name}-bastion"
  image       = var.image
  server_type = var.bastion_server_type
  location    = var.location
  ssh_keys    = [hcloud_ssh_key.this.id]

  user_data = templatefile("${path.module}/templates/bastion-cloud-init.yaml.tftpl", {
    target_ip = local.first_node_private_ip
    ssh_user  = "root"
  })

  network {
    network_id = module.network.network_id
    ip         = local.bastion_private_ip
  }

  firewall_ids = [hcloud_firewall.bastion.id]
}

module "servers" {
  source            = "./modules/hcloud-servers"
  name              = var.project_name
  role              = "server"
  count             = var.server_count
  image             = var.image
  server_type       = var.server_type
  location          = var.location
  ssh_key_id         = hcloud_ssh_key.this.id
  network_id        = module.network.network_id
  subnet_cidr       = local.subnet_cidr
  ip_offset         = 10
  user_data         = templatefile("${path.module}/templates/cloud-init.yaml.tftpl", {
    is_bootstrap      = "${count.index == 0 ? true : false}"
    lb_ip            = "${module.lb.private_ip}"
    k3s_token        = random_password.k3s_token.result
    pod_cidr         = var.pod_cidr
    service_cidr     = var.service_cidr
    longhorn_version = var.longhorn_version
    k3s_version      = var.k3s_version
  })
  enable_public_ssh = var.enable_public_ssh
  ssh_allowed_cidrs = ["${local.bastion_private_ip}/32"]
  internal_cidr     = local.internal_cidr
}

module "lb" {
  source      = "./modules/hcloud-lb"
  name        = "${var.project_name}-api"
  location    = var.location
  lb_type     = var.lb_type
  network_id  = module.network.network_id
  server_ids  = module.servers.ids
}
