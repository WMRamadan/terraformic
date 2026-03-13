output "load_balancer_public_ip" {
  value = module.lb.public_ip
}

output "load_balancer_private_ip" {
  value = module.lb.private_ip
}

output "server_public_ips" {
  value = module.servers.ipv4
}

output "bastion_public_ip" {
  value = hcloud_server.bastion.ipv4_address
}

output "bastion_private_ip" {
  value = hcloud_server.bastion.network[0].ip
}
