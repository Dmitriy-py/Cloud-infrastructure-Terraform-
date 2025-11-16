resource "yandex_container_registry" "app_registry" {
  name        = "final-project-registry"
  folder_id   = var.yc_folder_id
}