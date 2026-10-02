resource "yandex_vpc_network" "ayn-net" {
  name      = var.vpc.network_name
  folder_id = var.folder_id
}

resource "yandex_vpc_gateway" "ayn_nat_gateway" {
  folder_id = var.folder_id
  name      = var.vpc.gateway_name
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "ayn_rt" {
  folder_id = var.folder_id
  name      = var.vpc.route_table_name
  network_id = yandex_vpc_network.ayn-net.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id = yandex_vpc_gateway.ayn_nat_gateway.id
  }
}

resource "yandex_vpc_subnet" "ayn-subnet" {
  for_each       = var.vpc.subnets

  name           = "${var.vpc.network_name}-${each.key}"
  zone           = each.key
  v4_cidr_blocks = [each.value]

  network_id = yandex_vpc_network.ayn-net.id
  route_table_id = yandex_vpc_route_table.ayn_rt.id
}

