resource "yandex_vpc_network" "main" {
  name = "final-project-vpc"
}

resource "yandex_vpc_subnet" "main" {
  name           = "final-project-subnet-${var.default_zone}"
  zone           = var.default_zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = var.vpc_cidr
}

resource "yandex_vpc_security_group" "app_sg" {
  name       = "app-security-group"
  network_id = yandex_vpc_network.main.id

  egress {
    protocol          = "ANY"
    v4_cidr_blocks    = var.allowed_cidr
  }

  dynamic "ingress" {
    for_each = var.ingress_ports
    content {
      protocol          = "TCP"
      port              = ingress.key
      v4_cidr_blocks    = var.allowed_cidr
    }
  }

  ingress {
    protocol          = "ANY"
    predefined_target = "self_security_group"
  }
}
