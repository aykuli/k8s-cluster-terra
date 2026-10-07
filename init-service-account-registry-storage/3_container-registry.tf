resource "yandex_container_registry" "ayn_registry" {
  name = var.container_registry_name
}

# --- СЕРВИСНЫЙ АККАУНТ для работы с CONTAINER REGISTRY - push/pull докер образа приложения ---
resource "yandex_iam_service_account" "registry_sa" {
  name        = "registry-sa"
  description = "Сервисный аккаунт для работы с образом прилодения в container registry"
  folder_id   = var.folder_id
  expires_at  =  "2027-01-01T15:04:05Z"
}

resource "yandex_container_registry_iam_binding" "cr_support" {
  registry_id = yandex_container_registry.ayn_registry.id
  role        = "container-registry.admin"
  members     = ["serviceAccount:${yandex_iam_service_account.registry_sa.id}"]
}

resource "yandex_iam_service_account_key" "registry_sa_key" {
  service_account_id = yandex_iam_service_account.registry_sa.id
}


output "registry" {
  value =  {
    id: yandex_container_registry.ayn_registry.id
    name: yandex_container_registry.ayn_registry.name
    registry_id: yandex_container_registry.ayn_registry.registry_id
    status: yandex_container_registry.ayn_registry.status
  }
}
output "registry_secrets" {
  description = "Authorized key для CI/CD репозитория с приложением"
  sensitive   = true
  value       =  {
    # Формируем JSON-строку для репозитория, котрое компилирет приложение и отправляет в yandex container registry
    yandex_iam_service_account_key: jsonencode({
      id                 = yandex_iam_service_account_key.registry_sa_key.id
      service_account_id = yandex_iam_service_account.registry_sa.id
      created_at         = yandex_iam_service_account_key.registry_sa_key.created_at
      key_algorithm      = yandex_iam_service_account_key.registry_sa_key.key_algorithm
      public_key         = yandex_iam_service_account_key.registry_sa_key.public_key
      private_key        = yandex_iam_service_account_key.registry_sa_key.private_key
    })
  }
}
