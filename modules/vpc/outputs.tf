output "subnet_id" {
  value       = yandex_vpc_subnet.main.id
}

output "security_group_ids" {
  value       = [yandex_vpc_security_group.app_sg.id]
}

output "network_id" {
  value       = yandex_vpc_network.main.id
}