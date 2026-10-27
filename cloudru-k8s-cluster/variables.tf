# --- PROVIDERS ----------
variable "project_id" {
  type        = string
  description = "Идентификатор проекта Cloud.ru"
}

variable "auth_key_id" {
  type        = string
  description = "Key ID ключа доступа"
  sensitive   = true
}

variable "auth_secret" {
  type        = string
  description = "Key Secret ключа доступа"
  sensitive   = true
}

variable "tenant_id" {
  type        = string
  description = "Идентификатор тенанта Object Storage"
}
# -------------------------

# --- CLUSTER NAME ---
variable "cluster_name" {
  type    = string
  default = "ayncluster"
}
# -------------------

# --- VPC ----------
variable "vpc_subnets" {
  # map: зона доступности -> CIDR подсети
  type    = map(string)
  default = {
    "ru.AZ-1" = "10.0.1.0/24"
    "ru.AZ-2" = "10.0.2.0/24"
    "ru.AZ-3" = "10.0.3.0/24"
  }
}
# ------------------

# --- SECURITY GROUP ---
variable "sg" {
  type = object({
    admin_cidr = string
  })
}
# ----------------------

# --- SSH ACCESS ---
variable "ssh_user" {
  type    = string
  default = "aynur"
}

variable "ssh_public_key" {
  type    = string
  description = "SSH публичный ключ для доступа к ВМ"
}
# ------------------

# --- VM CONFIG ---
variable "vm" {
  type = object({
    name          = string
    password      = optional(string, null)
    image_family  = string
    platform_id   = string
    disk_type     = string
    disk_size     = number
    cores         = number
    memory        = number
    core_fraction = number
  })
  default = {
    name          = "vm"
    image_family  = "ubuntu-2204-lts"
    platform_id   = "standard-v3"
    disk_type     = "network-hdd"
    disk_size     = 30
    cores         = 2
    memory        = 2
    core_fraction = 20
  }
}
# -----------------

# --- SERVICE ACCOUNT ---
variable "service_account_image_puller_id" {
  type        = string
  description = "ID сервисного аккаунта с правами pull образов из реестра"
}
# -----------------------
