resource "hcloud_firewall" "this" {
  name = "${var.name}-${var.role}-fw"

  dynamic "rule" {
    for_each = var.enable_public_ssh ? [1] : []
    content {
      direction = "in"
      protocol  = "tcp"
      port      = "22"
      source_ips = ["0.0.0.0/0", "::/0"]
    }
  }

  dynamic "rule" {
    for_each = length(var.ssh_allowed_cidrs) > 0 ? [1] : []
    content {
      direction = "in"
      protocol  = "tcp"
      port      = "22"
      source_ips = var.ssh_allowed_cidrs
    }
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
    source_ips = [var.internal_cidr]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "2379-2380"
    source_ips = [var.internal_cidr]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "9345"
    source_ips = [var.internal_cidr]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "8472"
    source_ips = [var.internal_cidr]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "30000-32767"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

}

resource "hcloud_server" "this" {
  count       = var.count
  name        = format("%s-%s-%02d", var.name, var.role, count.index + 1)
  image       = var.image
  server_type = var.server_type
  location    = var.location
  ssh_keys    = [var.ssh_key_id]

  user_data = var.user_data

  network {
    network_id = var.network_id
    ip         = cidrhost(var.subnet_cidr, var.ip_offset + count.index)
  }

  firewall_ids = [hcloud_firewall.this.id]
}
