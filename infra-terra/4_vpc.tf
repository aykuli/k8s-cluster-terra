resource "yandex_vpc_network" "ayn-net" {
  name      = "${var.cluster_name}-network"
  folder_id = var.folder_id
}

# resource "yandex_vpc_gateway" "ayn_nat_gateway" {
#   folder_id = var.folder_id
#   name      = "${var.cluster_name}-nat"
#   shared_egress_gateway {}
# }

# resource "yandex_vpc_route_table" "ayn_rt" {
#   folder_id = var.folder_id
#   name      = "${var.cluster_name}-rt"
#   network_id = yandex_vpc_network.ayn-net.id

#   static_route {
#     destination_prefix = "0.0.0.0/0"
#     gateway_id = yandex_vpc_gateway.ayn_nat_gateway.id
#   }
# }

resource "yandex_vpc_subnet" "ayn-subnet" {
  for_each       = var.vpc_subnets

  name           = "${var.cluster_name}-subnet-${each.key}"
  zone           = each.key
  v4_cidr_blocks = [each.value]

  network_id = yandex_vpc_network.ayn-net.id
  # route_table_id = yandex_vpc_route_table.ayn_rt.id
}

