resource "yandex_vpc_network" "main" {
  name = var.vpc_name
}

resource "yandex_vpc_subnet" "main" {
  name           = "final-project-subnet-${var.zone}"
  zone           = var.zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = var.vpc_cidr_blocks
}

resource "yandex_vpc_security_group" "app_sg" {
  name       = "app-security-group"
  network_id = yandex_vpc_network.main.id

  egress {
    protocol          = "ANY"
    v4_cidr_blocks    = var.allowed_cidr
    description       = "Allow all outgoing traffic"
  }

  dynamic "ingress" {
    for_each = var.ingress_ports
    content {
      protocol          = "TCP"
      port              = ingress.key
      v4_cidr_blocks    = var.allowed_cidr
      description       = ingress.value
    }
  }

  ingress {
    protocol          = "ANY"
    predefined_target = "self_security_group"
  }
}