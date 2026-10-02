resource "yandex_container_registry" "ayn_registry" {
  name = var.container_registry_name
}

# --- SERVICE ACCOUNT FOR GITHUB ACTIONS TO SAVE IMAGE IN REGISTRY ---
resource "yandex_iam_service_account" "github-action-sa" {
  name        = "github-action-sa"
  description = "Service account for github actions"
  folder_id   = var.folder_id
  expires_at  =  "2027-01-01T15:04:05Z"
}

resource "yandex_container_registry_iam_binding" "pusher" {
  registry_id = yandex_container_registry.ayn_registry.id
  role        = "container-registry.admin"
  members     = ["serviceAccount:${yandex_iam_service_account.github-action-sa.id}"]
}

resource "yandex_iam_service_account_key" "github-actions-sa-key" {
  service_account_id = yandex_iam_service_account.github-action-sa.id
}


output "registry" {
  value =  {
    id: yandex_container_registry.ayn_registry.id
    name: yandex_container_registry.ayn_registry.name
    registry_id: yandex_container_registry.ayn_registry.registry_id
    status: yandex_container_registry.ayn_registry.status
  }
}
output "github_actions_secrets" {
  description = "Authorized key for GitHub Secrets fro my workflow"
  sensitive   = true
  value       =  {
    # Формируем JSON-строку для YC_SA_JSON_CREDENTIALS
    yandex_iam_service_account_key: jsonencode({
      id                 = yandex_iam_service_account_key.github-actions-sa-key.id
      service_account_id = yandex_iam_service_account.github-action-sa.id
      created_at         = yandex_iam_service_account_key.github-actions-sa-key.created_at
      key_algorithm      = yandex_iam_service_account_key.github-actions-sa-key.key_algorithm
      public_key         = yandex_iam_service_account_key.github-actions-sa-key.public_key
      private_key        = yandex_iam_service_account_key.github-actions-sa-key.private_key
    })
  }
}
