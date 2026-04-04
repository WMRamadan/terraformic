output "haproxy_ip" {
  value = var.haproxy_ip
}

output "k3s_node_ips" {
  value = var.k3s_node_ips
}

output "kube_api_endpoint" {
  value = "https://${var.haproxy_ip}:6443"
}

output "ssh_user" {
  value = var.ssh_username
}

output "k3s_node_ssh_commands" {
  value = [for ip in var.k3s_node_ips : "ssh ${var.ssh_username}@${ip}"]
}
