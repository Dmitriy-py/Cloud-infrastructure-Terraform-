module "vpc_network" {
  source = "./modules/vpc"

  vpc_name        = var.vpc_name
  zone            = var.default_zone
  vpc_cidr_blocks = var.vpc_cidr
  allowed_cidr    = var.allowed_cidr
  ingress_ports   = var.ingress_ports
}