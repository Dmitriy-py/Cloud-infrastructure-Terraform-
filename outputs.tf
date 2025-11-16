output "app_server_public_ips" {
  value       = yandex_compute_instance.app_vm[*].network_interface[0].nat_ip_address
}

output "mysql_host" {
  value       = yandex_mdb_mysql_cluster.app_db_cluster.host[0].fqdn
}

output "container_registry_id" {
  value       = yandex_container_registry.app_registry.id
}
