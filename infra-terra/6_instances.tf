data "yandex_compute_image" "ubuntu" {
  family = var.vms_resources.web.image_family
}

resource "yandex_compute_instance" "bastion" {
  name = var.vm.bastion.name
  zone = var.vm.bastion.zone

  network_interface {
    subnet_id          = yandex_vpc_subnet.ayn-subnet[var.vm.bastion.zone].id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.ayn-sg.id]
  }
  resources {
    cores = 2
    memory = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id  = data.yandex_compute_image.ubuntu.image_id
    }
  }

  scheduling_policy {
    preemptible = true
  }

  metadata = {
    ssh-keys = "${var.vm.user}:${file("~/.ssh/id_rsa.pub/")}"
  }
}

resource "yandex_compute_instance" "private" {
  for_each = yandex_vpc_subnet.ayn-subnet

  name = "private-${each.key}"
  zone = each.value.zone

  network_interface {
    subnet_id          = each.value.id
    nat                = false
    security_group_ids = [yandex_vpc_security_group.ayn-private-sg.id]
  }
 resources {
    cores = 2
    memory = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id  = data.yandex_compute_image.ubuntu.image_id
    }
  }

  scheduling_policy {
    preemptible = true
  }
  
  metadata = {
    ssh-keys = "${var.vm.user}:${file("~/.ssh/id_rsa.pub/")}"
  }
}