provider "libvirt" {
  uri = "qemu+ssh://${var.qemu_user}@${var.qemu_host}/system?sshauth=privkey&keyfile=${var.qemu_ssh_private_key_path}"
}

locals {
  k3s_nodes = {
    for idx, ip in var.k3s_node_ips :
    format("%s-node-%02d", var.project_name, idx + 1) => {
      ip    = ip
      first = idx == 0
    }
  }

  haproxy_cfg = templatefile("${path.module}/templates/haproxy.cfg.tftpl", {
    server_ips = var.k3s_node_ips
  })
}

resource "libvirt_pool" "k8s" {
  name = var.libvirt_pool_name
  type = "dir"
  path = var.libvirt_pool_path
}

resource "libvirt_network" "k8s" {
  name      = var.network_name
  mode      = "nat"
  domain    = var.network_domain
  addresses = [var.network_cidr]
  autostart = true
}

resource "libvirt_volume" "ubuntu_base" {
  name   = "${var.project_name}-ubuntu-base.qcow2"
  pool   = libvirt_pool.k8s.name
  source = var.ubuntu_image_url
  format = "qcow2"
}

resource "libvirt_volume" "haproxy_disk" {
  name           = "${var.project_name}-haproxy.qcow2"
  pool           = libvirt_pool.k8s.name
  base_volume_id = libvirt_volume.ubuntu_base.id
  size           = var.vm_disk_size_bytes
}

resource "libvirt_volume" "k3s_disk" {
  for_each       = local.k3s_nodes
  name           = "${each.key}.qcow2"
  pool           = libvirt_pool.k8s.name
  base_volume_id = libvirt_volume.ubuntu_base.id
  size           = var.vm_disk_size_bytes
}

resource "libvirt_cloudinit_disk" "haproxy" {
  name = "${var.project_name}-haproxy-cloudinit.iso"
  pool = libvirt_pool.k8s.name

  user_data = templatefile("${path.module}/templates/cloud-init-haproxy.yaml.tftpl", {
    hostname           = "${var.project_name}-haproxy"
    ssh_username       = var.ssh_username
    ssh_password       = var.ssh_password
    ssh_authorized_key = var.ssh_authorized_key
    haproxy_cfg        = local.haproxy_cfg
  })
}

resource "libvirt_cloudinit_disk" "k3s" {
  for_each = local.k3s_nodes
  name     = "${each.key}-cloudinit.iso"
  pool     = libvirt_pool.k8s.name

  user_data = templatefile("${path.module}/templates/cloud-init-k3s.yaml.tftpl", {
    hostname           = each.key
    node_ip            = each.value.ip
    bootstrap          = each.value.first
    lb_ip              = var.haproxy_ip
    k3s_token          = var.k3s_token
    k3s_version        = var.k3s_version
    cluster_cidr       = var.k3s_cluster_cidr
    service_cidr       = var.k3s_service_cidr
    ssh_username       = var.ssh_username
    ssh_password       = var.ssh_password
    ssh_authorized_key = var.ssh_authorized_key
  })
}

resource "libvirt_domain" "haproxy" {
  name      = "${var.project_name}-haproxy"
  memory    = var.haproxy_memory_mb
  vcpu      = var.haproxy_vcpu
  autostart = true

  cloudinit = libvirt_cloudinit_disk.haproxy.id

  network_interface {
    network_id     = libvirt_network.k8s.id
    wait_for_lease = true
    addresses      = [var.haproxy_ip]
  }

  disk {
    volume_id = libvirt_volume.haproxy_disk.id
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type        = "spice"
    listen_type = "none"
    autoport    = true
  }

  qemu_agent = true
}

resource "libvirt_domain" "k3s" {
  for_each  = local.k3s_nodes
  name      = each.key
  memory    = var.k3s_node_memory_mb
  vcpu      = var.k3s_node_vcpu
  autostart = true

  cloudinit = libvirt_cloudinit_disk.k3s[each.key].id

  network_interface {
    network_id     = libvirt_network.k8s.id
    wait_for_lease = true
    addresses      = [each.value.ip]
  }

  disk {
    volume_id = libvirt_volume.k3s_disk[each.key].id
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type        = "spice"
    listen_type = "none"
    autoport    = true
  }

  qemu_agent = true

  depends_on = [libvirt_domain.haproxy]
}

check "node_counts" {
  assert {
    condition     = length(var.k3s_node_ips) == 3
    error_message = "k3s_node_ips must contain exactly 3 IPs."
  }
}
