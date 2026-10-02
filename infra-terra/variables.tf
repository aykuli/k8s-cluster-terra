# --- PROVIDERS ----------
variable "cloud_id" {
  type = string
}
variable "folder_id" {
  type = string
}

variable "keys_path" {
  type = string
}
# Zone	Subnet Name	CIDR Block (Example)	Purpose
# ru-central1-a	subnet-a	10.0.1.0/24	Resources in Zone A
# ru-central1-b	subnet-b	10.0.2.0/24	Resources in Zone B
# ru-central1-c	subnet-c	10.0.3.0/24	Resources in Zone C
variable "default_zone" {
  type    = string
  default = "ru-central1-a"
}
# -----------------------

# --- SERVICE ACCOUNT ---
variable "sa_name" {
  type    = string
  default = "diplomaSA"
}
# -----------------------

# --- CONTAINER REGISTRY ---
variable "container_registry_name" {
  type = string
  default = "ayn-registry"
}
# --------------------------

# --- SECURITY GROUP -------
variable "sg" {
  type = object({
    name       = string
    admin_cidr = string
  })
}
variable "sg-private" {
  type = object({
    name       = string
    admin_cidr = string
  })
}
# --------------------------

# --- VPC ------------------
variable "vpc" {
  type = object({
    network_name     = string
    subnet_name      = string
    gateway_name     = string
    route_table_name = string
    # map: зона доступности -> CIDR подсети
    subnets = map(string)
  })
  default = {
    network_name     = "ayn-netw"
    subnet_name      = "ayn-subn"
    gateway_name     = "ayn-gateway",
    route_table_name = "ayn-rt"
    subnets = {
      "ru-central1-a" = "10.0.1.0/24"
      "ru-central1-b" = "10.0.2.0/24"
      "ru-central1-d" = "10.0.3.0/24"
    }
  }
}
# -----------------------

# --- INSTANCES----------
variable "vm" {
  type = object({
    user     = string
    keyh = string
    bastion  = object({
      name = string
      zone = string
    })
  })
}
# -----------------------


# --- DNS ---
variable "dns_zone" {
  type = object({
    name        = string
    zone        = string
    is_public   = bool
    description = optional(string)
    recordset = list(object({
      name = string
      data = list(string)
      type = string
      ttl  = number
    }))
  })
}
# ---
