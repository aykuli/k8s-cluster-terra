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
  default = "diploma-sa"
}
# -----------------------

# --- CONTAINER REGISTRY ---
variable "container_registry_name" {
  type = string
  default = "ayn-registry"
}
# --------------------------

