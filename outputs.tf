output "app_server_public_ips" {
  value = yandex_compute_instance.app_vm[*].network_interface[0].nat_ip_address
}

output "database_fqdn" {
  value       = yandex_mdb_mysql_cluster.app_db_cluster.primary_host[0].fqdn
}

output "main_subnet_id" {
  value       = module.vpc_network.subnet_id
}

output "main_vpc_id" {
  value       = module.vpc_network.network_id
}

output "app_security_group_ids" {
  value       = module.vpc_network.security_group_ids
}
