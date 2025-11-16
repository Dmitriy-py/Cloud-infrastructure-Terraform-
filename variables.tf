variable "yc_cloud_id" { type = string }
variable "yc_folder_id" { type = string }

variable "default_zone" {
  description = "Default availability zone for resources."
  type        = string
  default     = "ru-central1-a"
}

variable "vpc_cidr" {
  description = "CIDR block for the subnet. Must be provided in tfvars."
  type        = list(string)
}

variable "vm_count" {
  description = "Number of application VMs to deploy (use count)."
  type        = number
  default     = 2
}

variable "vm_cores" {
  description = "Number of CPU cores for the application VM."
  type        = number
  default     = 2
}

variable "vm_memory" {
  description = "Amount of RAM (in GB) for the application VM."
  type        = number
  default     = 2
}

variable "vm_disk_size" {
  description = "Size of the boot disk (in GB)."
  type        = number
  default     = 20
}

variable "vm_disk_type" {
  description = "Type of disk for the VM."
  type        = string
  default     = "network-ssd"
}

variable "container_optimized_image_id" {
  description = "ID of the Yandex Container Optimized Image (COI) with Docker preinstalled."
  type        = string
  default     = "fd8b2p3ts70pbpidnm"
}

variable "ssh_user" {
  description = "User name for SSH."
  type        = string
  default     = "yc-user"
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key file."
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "ingress_ports" {
  description = "Map of inbound rules {port: description}"
  type = map(string)
  default = {
    "22"  = "SSH access",
    "80"  = "HTTP access",
    "443" = "HTTPS access"
  }
}

variable "allowed_cidr" {
  description = "CIDR block allowed for external ingress."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "db_password" {
  description = "Password for the DB user."
  type        = string
  sensitive   = true
}

variable "db_version" {
  description = "MySQL version."
  type        = string
  default     = "8.0"
}

variable "db_disk_size" {
  description = "Disk size for the database cluster (in GB)."
  type        = number
  default     = 10
}

variable "db_disk_type" {
  description = "Disk type for the database."
  type        = string
  default     = "network-ssd"
}
