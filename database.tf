resource "yandex_mdb_mysql_cluster" "app_db_cluster" {
  name        = "app-mysql-cluster"
  environment = "PRESTABLE" 
  network_id  = yandex_vpc_network.main.id
  version     = var.db_version

  resources {
    resource_preset_id = "s2.micro" 
    disk_type_id       = var.db_disk_type
    disk_size          = var.db_disk_size
  }

  host {
    zone      = var.default_zone
    subnet_id = yandex_vpc_subnet.main.id
  }

  database {
    name = "app_database"
  }

  user {
    name     = "app_user"
    password = var.db_password
    permission {
      database_name = "app_database"
      roles         = ["ALL"] 
    }
  }
}