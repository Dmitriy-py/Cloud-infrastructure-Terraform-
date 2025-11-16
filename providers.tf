terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
    }
  }
  required_version = "~> 1.13.0"

  backend "s3" {
    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }
    bucket = "ter-hw04-final-bucket-999"
    region = "ru-central1" 
    key    = "terraform/final_project.tfstate"
    
    use_path_style = true 
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true 
    skip_s3_checksum            = true 
  }

}

provider "yandex" {
  service_account_key_file = "key.json" 
  
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = var.default_zone
}