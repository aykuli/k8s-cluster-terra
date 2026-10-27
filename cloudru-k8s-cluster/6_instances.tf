data "cloudru_evolution_compute_image_collection" "ubuntu" {
  project_id = var.project_id
  page_size  = 100
}


# =============================================================================
# Конфигурация cloud-init
# =============================================================================

locals {
  cloud_config = templatefile("${path.module}/cloud-init.yaml.tpl", {
    ssh_public_key = var.ssh_public_key
    password       = var.vm.password
  })
}



# locals {
#   zones = keys(var.vpc_subnets)
#   common_metadata = {
#     ssh-keys = "${var.ssh_user}:${var.ssh_public_key}"
#     user-data = templatefile("./cloud-init.yaml", {
#       ssh_user       = var.ssh_user
#       ssh_public_key = var.ssh_public_key
#     })
#   }
# }

# # ---------- МАСТЕР ВМ ----------
# resource "cloudru_evolution_compute_instance" "master" {
#   name        = "${var.cluster_name}-master"
#   hostname    = "${var.cluster_name}-master"
#   platform_id = var.vm.platform_id
#   zone        = local.zones[0]

#   network_interface {
#     subnet_id        = cloudru_evolution_vpc_subnet.ayn-subnet[local.zones[0]].id
#     security_group_ids = [cloudru_evolution_vpc_security_group.ayn-sg.id]
#     nat              = true
#   }

#   resources {
#     cores         = var.vm.cores
#     memory        = var.vm.memory
#     core_fraction = var.vm.core_fraction
#   }

#   boot_disk {
#     initialize_params {
#       image_id = data.cloudru_evolution_compute_image.ubuntu.image_id
#       type     = var.vm.disk_type
#       size     = var.vm.disk_size
#     }
#   }

#   scheduling_policy { preemptible = true }
#   allow_stopping_for_update = true

#   service_account_id = var.service_account_image_puller_id
#   metadata           = local.common_metadata
# }

# output "master" {
#   value = {
#     name       = cloudru_evolution_compute_instance.master.name
#     public_ip  = cloudru_evolution_compute_instance.master.network_interface[0].nat_ip_address
#     private_ip = cloudru_evolution_compute_instance.master.network_interface[0].ip_address
#   }
# }

# # ---------- 3 ВОРКЕР ВМ-ы в разных зонах Cloud.ru ----------
# resource "cloudru_evolution_compute_instance" "worker" {
#   for_each = cloudru_evolution_vpc_subnet.ayn-subnet

#   name        = "${var.cluster_name}-worker-${each.key}"
#   hostname    = "${var.cluster_name}-worker-${each.key}"
#   platform_id = var.vm.platform_id
#   zone        = each.key

#   network_interface {
#     subnet_id          = each.value.id
#     security_group_ids = [cloudru_evolution_vpc_security_group.ayn-sg.id]
#     nat                = true
#   }

#   resources {
#     cores         = var.vm.cores
#     memory        = var.vm.memory
#     core_fraction = var.vm.core_fraction
#   }

#   boot_disk {
#     initialize_params {
#       image_id = data.cloudru_evolution_compute_image.ubuntu.image_id
#       type     = var.vm.disk_type
#       size     = var.vm.disk_size
#     }
#   }

#   scheduling_policy { preemptible = true }
#   allow_stopping_for_update = true

#   service_account_id = var.service_account_image_puller_id
#   metadata           = local.common_metadata
# }

# output "workers" {
#   value = [
#     for w in cloudru_evolution_compute_instance.worker : {
#       name       = w.name
#       public_ip  = w.network_interface[0].nat_ip_address
#       private_ip = w.network_interface[0].ip_address
#     }
#   ]
# }
