# resource "cloudru_evolution_vpc_vpc" "ayn-net" {
#   name        = "ayn-net"
#   description = "VPC network для кластера Kubernetes"
#   project_id  = var.project_id
#     timeouts {
#     create = "60m"
#     update = "30m"
#     delete = "20m"
#   }
#   # Игнорировать изменения таймаутов: это предотвращает  лишние обновления ресурса при смене значений таймаутов в конфигурации
#   # Но следует учитывать, что метод delete в ресурсе читает значение таймаута из стейта и, если его нужно изменить, то этот блок стоит закомментировать
#   lifecycle {
#     ignore_changes = [timeouts]
#   }
# }

# # https://cloud.ru/docs/terraform-evolution/ug/topics/reference/resources/cloudru_evolution_compute_subnet?highlight=subnet&source-platform=Evolution
# resource "cloudru_evolution_compute_subnet" "ayn-subnet" {
#   for_each       = var.vpc_subnets

#   project_id     = var.project_id

#   zone = {
#     name = each.key
#   }

#   name           = "${var.cluster_name}-subnet-${each.key}"
#   description    = "Subnet for zone ${each.key}"
#   routed_network = true
#   default        = false
#   vpc_id         = cloudru_evolution_vpc_vpc.ayn-net.id

#   dns_servers = {
#     value = ["8.8.4.4", "8.8.8.8"]
#   }
#     prefix_length = 384166316
#   # Позволяет переопределить дефолтный таймаут провайдера для определенного метода. Если нужно указать бесконечный таймаут, то нужно указать например 0s, тогда таймаута не будет.
#   timeouts {
#     create = "60m"
#     update = "30m"
#     delete = "20m"
#   }
#   # Игнорировать изменения таймаутов: это предотвращает  лишние обновления ресурса при смене значений таймаутов в конфигурации
#   # Но следует учитывать, что метод delete в ресурсе читает значение таймаута из стейта и, если его нужно изменить, то этот блок стоит закомментировать
#   lifecycle {
#     ignore_changes = [timeouts]
#   }
# }
