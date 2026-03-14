resource "hcloud_server" "this" {
  count       = var.node_count
  name        = format("%s-%s-%02d", var.name, var.role, var.name_offset + count.index + 1)
  image       = var.image
  server_type = var.server_type
  location    = var.location
  ssh_keys    = var.ssh_key_ids

  user_data = templatefile(var.user_data_template, {
    is_bootstrap      = var.bootstrap && count.index == 0 ? "true" : "false"
    lb_ip            = var.lb_ip
    bootstrap_ip     = var.bootstrap_ip
    k3s_token        = var.k3s_token
    pod_cidr         = var.pod_cidr
    service_cidr     = var.service_cidr
    k3s_version      = var.k3s_version
  })

  network {
    network_id = var.network_id
    ip         = cidrhost(var.subnet_cidr, var.ip_offset + count.index)
  }

  firewall_ids = var.firewall_ids
}
