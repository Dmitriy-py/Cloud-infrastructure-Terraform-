variable "vpc_name" {
  type = string
}

variable "zone" {
  type = string
}

variable "vpc_cidr_blocks" {
  type = list(string)
}

variable "allowed_cidr" {
  type = list(string)
}

variable "ingress_ports" {
  type = map(string) # { 22: "SSH", 80: "HTTP", ... }
}