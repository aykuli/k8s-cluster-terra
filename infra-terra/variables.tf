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

# --- SECURITY GROUP -------
variable "sg" {
  type = object({
    admin_cidr = string
  })
}
variable "sg-private" {
  type = object({
    admin_cidr = string
  })
}
# --------------------------

# --- VPC ------------------
variable "cluster_name" {
  type = string
  default = "ayn-cluster"
}
variable "vpc_subnets" {
    # map: зона доступности -> CIDR подсети
  type = map(string)
  default = {
    "ru-central1-a" = "10.0.1.0/24"
    "ru-central1-b" = "10.0.2.0/24"
    "ru-central1-d" = "10.0.3.0/24"
  }
}
# -----------------------

# --- VMs ----------
variable "ssh_user" {
  type = string
}
variable "ssh_public_key" {
  type = string
}

variable "vm" {
  type = object({
    image_family  = string
    platform_id   = string
    name          = string
    hostname      = string
    disk_type     = string
    disk_size     = number
    preemptible   = bool
    cores         = number
    memory        = number
    core_fraction = number
    nat           = bool
  })
  default = {
    image_family  = "ubuntu-2204-lts"
    platform_id   = "standard-v1"
    disk_type     = "network-hdd"
    disk_size     = 30
    cores         = 2
    memory        = 2
    core_fraction = 20
  }
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
