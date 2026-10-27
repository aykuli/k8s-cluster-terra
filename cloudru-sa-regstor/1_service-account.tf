# --- СЕРВИСНЫЙ АККАУНТ -------------------------------
resource "cloudru_evolution_iam_service_account" "diploma_sa" {
  name        = var.sa_name
  description = "Сервисный аккаунт для дипломной работы (Cloud.ru)"
  target = {
    project_id = var.project_id
  }
}
# --- КЛЮЧИ ------------------------------------------
# --- Ключ доступа для сервисного аккаунта ---
resource "cloudru_evolution_iam_access_key" "diploma_sa_static_key" {
  service_account_id = cloudru_evolution_iam_service_account.diploma_sa.id
  description        = "Static access key для хранилища tfstate terraform проекта с k8s кластером (Cloud.ru)"
  ttl                = "0"  # 0 — бессрочный ключ; можно указать "24h", "7d" и т.д.
}

data "cloudru_evolution_iam_api_key_product_collection" "products" {}
resource "cloudru_evolution_iam_api_key" "diploma_sa_key" {
  name               = "diploma-sa-api-key"
  description        = "Авторизованный ключ для проекта кластера Kubernetes (Cloud.ru)"
  service_account_id = cloudru_evolution_iam_service_account.diploma_sa.id
  enabled            = true

  # Обязательный параметр: коды продуктов
  product_codes = [
    for p in data.cloudru_evolution_iam_api_key_product_collection.products.products :
    p.code if p.name != ""  # отфильтруйте нужные по имени
  ]
}


# --- РОЛИ -------------------------------------------
# s3e.admin — полный доступ к Object Storage
resource "cloudru_evolution_iam_permission" "diploma_sa_storage" {
  resource_id = var.project_id
  subject_id  = cloudru_evolution_iam_service_account.diploma_sa.id
  role_identifier = {
    role_name = "s3e.admin"
  }
}
# vpc.admin — полный доступ к VPC
resource "cloudru_evolution_iam_permission" "diploma_sa_vpc" {
  resource_id = var.project_id
  subject_id  = cloudru_evolution_iam_service_account.diploma_sa.id
  role_identifier = {
    role_name = "vpc.admin"
  }
}
# eiv.admin — полный доступ к виртуальным машинам
resource "cloudru_evolution_iam_permission" "diploma_sa_compute" {
  resource_id = var.project_id
  subject_id  = cloudru_evolution_iam_service_account.diploma_sa.id
  role_identifier = {
    role_name = "eiv.admin"
  }
}
# platform.project.iam-admin — управление пользователями и сервисными аккаунтами
resource "cloudru_evolution_iam_permission" "diploma_sa_user" {
  resource_id = var.project_id
  subject_id  = cloudru_evolution_iam_service_account.diploma_sa.id

  role_identifier = {
    role_name = "platform.project.iam-admin"
  }
}

# --- ВЫВОД -------------------------------------------
output "diploma_sa" {
  description = "Детали сервисного аккаунта"
  value = {
    id   = cloudru_evolution_iam_service_account.diploma_sa.id
    name = cloudru_evolution_iam_service_account.diploma_sa.name
  }
}

output "s3_key" {
  description = "Cloud.ru S3 key"
  value       = {
    key = cloudru_evolution_iam_access_key.diploma_sa_static_key.key_id,
    secret = cloudru_evolution_iam_access_key.diploma_sa_static_key.secret
  }
  sensitive   = true
}

output "diploma_sa_secrets" {
  description = "Authorized key для CI/CD репозитория с приложением"
  sensitive   = true
  value = {
    yandex_iam_service_account_key = jsonencode({
      id                 = cloudru_evolution_iam_api_key.diploma_sa_key.id
      service_account_id = cloudru_evolution_iam_service_account.diploma_sa.id
      created_at         = cloudru_evolution_iam_api_key.diploma_sa_key.created_at
      secret             = cloudru_evolution_iam_api_key.diploma_sa_key.secret
    })
  }
}
