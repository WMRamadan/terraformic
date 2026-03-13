output "load_balancer_public_ip" {
  value = module.lb.public_ip
}

output "load_balancer_private_ip" {
  value = module.lb.private_ip
}

output "server_public_ips" {
  value = module.servers.ipv4
}

output "vault_endpoint" {
  value = "https://${module.servers.ipv4[0]}:${var.vault_nodeport}"
}
