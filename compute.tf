data "yandex_compute_image" "coi_latest" {
  family = "container-optimized-image" 
}

data "yandex_iam_service_account" "app_sa" {
  name = "sa-profile"
}


locals {
  ssh_key_content = file(var.ssh_public_key_path)
  vm_metadata = {
    user-data = <<-EOT
      #cloud-config
      users:
        - name: ${var.ssh_user}
          groups: sudo
          shell: /bin/bash
          sudo: 'ALL=(ALL) NOPASSWD:ALL'
          ssh_authorized_keys:
            - ${local.ssh_key_content}
      runcmd:
        - [ sh, -c, "sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose" ]
        - [ sh, -c, "sudo chmod +x /usr/local/bin/docker-compose" ]
        - [ sh, -c, "sudo usermod -aG docker ${var.ssh_user}" ]
      EOT
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
    subnet_id          = yandex_vpc_subnet.main.id
    security_group_ids = [yandex_vpc_security_group.app_sg.id]
    nat                = true
  }

  metadata = local.vm_metadata
}