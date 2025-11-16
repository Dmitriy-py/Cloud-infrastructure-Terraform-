output "app_server_public_ips" {
  description = "Public IP addresses of application VMs."
  value       = yandex_compute_instance.app_vm[*].network_interface[0].nat_ip_address
}

output "mysql_host" {
  description = "Internal FQDN for MySQL cluster."
  value       = yandex_mdb_mysql_cluster.app_db_cluster.host[0].fqdn
}

output "container_registry_id" {
  description = "ID of the created Container Registry."
  value       = yandex_container_registry.app_registry.id
}