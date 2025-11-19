variable "yc_cloud_id" { type = string }
variable "yc_folder_id" { type = string }

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
}

variable "vpc_name" {
  description = "Name for the VPC network."
  type        = string
  default     = "final-project-vpc" 
}

variable "vpc_cidr" {
  type        = list(string)
}

variable "vm_count" {
  type        = number
  default     = 2
}

variable "vm_cores" {
  type        = number
  default     = 2
}

variable "vm_memory" {
  type        = number
  default     = 2
}

variable "vm_disk_size" {
  type        = number
  default     = 20
}

variable "vm_disk_type" {         
  type        = string
  default     = "network-ssd"
}

variable "container_optimized_image_id" {    
  type        = string
  default     = "fd8b2p3ts70pbpidnm"
}

variable "ssh_user" {
  type        = string
  default     = "yc-user"
}

variable "ssh_public_key_path" {
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "ingress_ports" {
  type = map(string)
  default = {
    "22"  = "SSH access",
    "80"  = "HTTP access",
    "443" = "HTTPS access"
  }
}

variable "allowed_cidr" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "db_password" {
  type        = string
  sensitive   = true
}

variable "db_version" {
  type        = string
  default     = "8.0"
}

variable "db_disk_size" {
  type        = number
  default     = 10
}

variable "db_disk_type" {
  type        = string
  default     = "network-ssd"
}
