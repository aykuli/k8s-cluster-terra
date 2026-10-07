# --- СЕРВИСНЫЙ АККАУНТ -------------------------------
resource "yandex_iam_service_account" "diploma-sa" {
  name        = var.sa_name
  description = "Сервисный аккаунт для дипломной работы"
  folder_id   = var.folder_id
  expires_at  =  "2027-01-01T15:04:05Z"
}

# S3 / Object Storage
resource "yandex_resourcemanager_folder_iam_member" "diploma_sa_storage" {
  folder_id = var.folder_id
  role      = "storage.admin" # для установки кредов(access_key/secret_key) нужны права admin
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
  role      = "compute.admin"
  member    = "serviceAccount:${yandex_iam_service_account.diploma-sa.id}"
}

# Пользователи
resource "yandex_resourcemanager_folder_iam_member" "diploma_sa_user" {
  folder_id = var.folder_id
  role      = "iam.serviceAccounts.user"
  member    = "serviceAccount:${yandex_iam_service_account.diploma-sa.id}"
}

resource "yandex_iam_service_account_static_access_key" "diploma_sa_static_key" {
  service_account_id = yandex_iam_service_account.diploma-sa.id
  description        = "Static access key для хранилища tfstate terraform проекта с k8s кластером"
}

output "diploma-sa" {
  description = "Детали сервисного аккаутна"
  value     = {
    id: yandex_iam_service_account.diploma-sa.id,
    name: yandex_iam_service_account.diploma-sa.name
  }
}

output "s3_access_key" {
  description = "Yandex Cloud S3 access key"
  value       = yandex_iam_service_account_static_access_key.diploma_sa_static_key.access_key
  sensitive   = true
}

output "s3_secret_key" {
  description = "Yandex Cloud S3 secret key"
  value       = yandex_iam_service_account_static_access_key.diploma_sa_static_key.secret_key
  sensitive   = true
}

resource "yandex_iam_service_account_key" "diploma_sa_key" {
  service_account_id = yandex_iam_service_account.diploma-sa.id
  description        = "Авторизованный ключ для проекта кластера Кубернетис"
}

output "diploma_sa_secrets" {
  description = "Authorized key для CI/CD репозитория с приложением"
  sensitive   = true
  value       =  {
    # Формируем JSON-строку для репозитория, котрое компилирет приложение и отправляет в yandex container registry
    yandex_iam_service_account_key: jsonencode({
      id                 = yandex_iam_service_account_key.diploma_sa_key.id
      service_account_id = yandex_iam_service_account.diploma-sa.id
      created_at         = yandex_iam_service_account_key.diploma_sa_key.created_at
      key_algorithm      = yandex_iam_service_account_key.diploma_sa_key.key_algorithm
      public_key         = yandex_iam_service_account_key.diploma_sa_key.public_key
      private_key        = yandex_iam_service_account_key.diploma_sa_key.private_key
    })
  }
}