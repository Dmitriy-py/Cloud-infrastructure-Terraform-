data "yandex_compute_image" "coi_latest" {
  family = "container-optimized-image" 
}

data "yandex_iam_service_account" "app_sa" {
  name = "sa-profile"
}

locals {
  ssh_key_content = file(var.ssh_public_key_path)

  vm_metadata = {
    user-data = templatefile("${path.module}/cloud-init.yaml.tftpl", {
      ssh_user       = var.ssh_user
      ssh_public_key = local.ssh_key_content
      db_host        = yandex_mdb_mysql_cluster.app_db_cluster.host[0].fqdn
      db_password    = var.db_password
      registry_id    = yandex_container_registry.app_registry.id
    })
  }
}

resource "yandex_compute_instance" "app_vm" {
  count = var.vm_count 

  name     = "app-server-${count.index + 1}"
  hostname = "app-server-${count.index + 1}" 
  zone     = var.default_zone

  service_account_id = data.yandex_iam_service_account.app_sa.id
  
  resources {
    cores  = var.vm_cores
    memory = var.vm_memory
  }

  scheduling_policy {
    preemptible = true
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.coi_latest.image_id
      size     = var.vm_disk_size
      type     = var.vm_disk_type
    }
  }

  network_interface {
    subnet_id          = module.vpc_network.subnet_id
    security_group_ids = module.vpc_network.security_group_ids
    nat                = true
  }

  metadata = local.vm_metadata
}