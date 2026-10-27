resource "cloudru_evolution_vpc_vpc" "ayn-net" {
  name        = "${var.cluster_name}-network"
  description = "VPC network для кластера Kubernetes"
  project_id  = var.project_id
    timeouts {
    create = "60m"
    update = "30m"
    delete = "20m"
  }
  # Игнорировать изменения таймаутов: это предотвращает  лишние обновления ресурса при смене значений таймаутов в конфигурации
  # Но следует учитывать, что метод delete в ресурсе читает значение таймаута из стейта и, если его нужно изменить, то этот блок стоит закомментировать
  lifecycle {
    ignore_changes = [timeouts]
  }
}

resource "cloudru_evolution_compute_subnet" "ayn-subnet" {
  for_each       = var.vpc_subnets

  project_id     = var.project_id

  zone_identifier = {
    name = each.key
  }

  name           = "${var.cluster_name}-subnet-${each.key}"
  description    = "Subnet for zone ${each.key}"
  routed_network = true
  default        = false
  vpc_id         = cloudru_evolution_vpc_vpc.ayn-net.id
  cidr           = [each.value]

  dns_servers = {
    value = ["8.8.4.4", "8.8.8.8"]
  }
}
