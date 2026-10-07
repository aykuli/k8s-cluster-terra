# --- SERVICE ACCOUNT -------------------------------
resource "yandex_iam_service_account" "diploma-sa" {
  name        = var.sa_name
  description = "Service account for diploma work"
  folder_id   = var.folder_id
  expires_at  =  "2027-01-01T15:04:05Z"
}

# S3 / Object Storage
resource "yandex_resourcemanager_folder_iam_member" "diploma_sa_storage" {
  folder_id = var.folder_id
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.diploma-sa.id}"
}

# Сети и их обслуживание
resource "yandex_resourcemanager_folder_iam_member" "diploma_sa_vpc" {
  folder_id = var.folder_id
  role      = "vpc.admin"
  member    = "serviceAccount:${yandex_iam_service_account.diploma-sa.id}"
}

# Виртуальные машины и их обслуживание
resource "yandex_resourcemanager_folder_iam_member" "diploma_sa_compute" {
  folder_id = var.folder_id
  role      = "compute.editor"
  member    = "serviceAccount:${yandex_iam_service_account.diploma-sa.id}"
}

resource "yandex_iam_service_account_static_access_key" "diploma-sa-static-key" {
  service_account_id = yandex_iam_service_account.diploma-sa.id
  description        = "Static access key for storage"
}

output "s3_access_key" {
  description = "Yandex Cloud S3 access key"
  value       = yandex_iam_service_account_static_access_key.diploma-sa-static-key.access_key
  sensitive   = true
}

output "s3_secret_key" {
  description = "Yandex Cloud S3 secret key"
  value       = yandex_iam_service_account_static_access_key.diploma-sa-static-key.secret_key
  sensitive   = true
}