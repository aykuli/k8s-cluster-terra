# --- PROVIDERS ----------
variable "project_id" {
  type = string
  description = "Идентификатор проекта"
}
variable "auth_key_id" {
  type = string
  description = "Key ID ключа доступа"
  sensitive   = true
}
variable "auth_secret" {
  type = string
  description = "Key Secret ключа доступа"
  sensitive   = true
}

variable "tenant_id" {
  type        = string
  description = "Идентификатор тенанта Object Storage (из ЛК → Object Storage → Параметры работы с API)"
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

# --- STORAGE --------------
variable "bucket" {
  type = object({
    name = string
    size = number
    unit = optional(string, null)
    type = optional(string, null)
  })
  default = {
    name = "diploma-tfstate-cloudru"
    size = 512
    unit = "MB"
    type = "BUCKET_SIZE"
  }
}
# --------------------------
