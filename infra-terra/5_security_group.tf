resource "yandex_vpc_security_group" "ayn-sg" {
  name        = var.sg.name
  description = "Security group for bastion host"
  network_id  = yandex_vpc_network.ayn-net.id

  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = [var.sg.admin_cidr]
    port           = 22
    description    = "Allow SSH from admin IP"
  }

  egress {
    protocol       = "ANY"
    description    = "Allow egress to internal network fro private VMs"
    v4_cidr_blocks = ["10.0.0.0/8"]
  } 
  egress {
    protocol       = "ANY"
    description    = "Allow to download from Internet whatever"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "ayn-sg-private" {
  name        = var.sg-private.name
  description = "Security group for private VMs behind bastion"
  network_id  = yandex_vpc_network.ayn-net.id

  # SSH только от группы безопасности бастиона
  ingress {
    protocol          = "TCP"
    description       = "Allow SSH from bastion security group"
    security_group_id = yandex_vpc_security_group.ayn-sg.id
    port              = 22
  }

  # Внутренний трафик между ВМ этой группы (например, БД, приложение)
  ingress {
    protocol          = "ANY"
    description       = "Allow traffic within private security group"
    predefined_target = "self_security_group"
  }
  
  egress {
    protocol       = "ANY"
    description    = "Allow to download from Internet whatever"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}