# ============================================
# Artifact Registry (Docker-образы)
# ============================================

# URI реестра: <имя-реестра>.cr.cloud.ru
# Аутентификация: через те же Key ID и Key Secret, что и для API
# Форматы: Docker, Debian, RPM, PyPI, NPM, Generic
# Типы доступа: приватный или публичный
# Поддержка: сканирование уязвимостей, карантин, политики хранения
resource "cloudru_evolution_artifact_registry_registry" "diploma-registry" {
  name           = var.container_registry_name
  project_id     = var.project_id
  registry_type  = "DOCKER"
  registry_mode  = "REGISTRY_MODE_LOCAL"
  is_public      = false
  tariff         = "PREMIUM"
  quarantine_mode = "DISABLED"

  retention_policy_is_enabled = true
  retention_policy = {
    action        = "DELETE"
    constraint    = "OLDER_THAN"
    value         = 30
    unit          = "d"
    on            = "LAST_PULLED_AT"
    only_untagged = false
  }
  timeouts {
    create = "60m"
    update = "30m"
    delete = "20m"
  }
  # Игнорировать изменения таймаутов: это предотвращает  лишние обновления ресурса при смене значений таймаутов в конфигурации
  # Но следует учитывать, что метод delete в ресурсе читает значение таймаута из стейта и, если его нужно изменить, то этот блок стоит закомментировать
  lifecycle {
    ignore_changes = [timeouts]
  }
}
# Роли для Artifact Registry
# Роль                Push  Pull  Управление реестром
# ar.admin	          ✅    ✅    ✅ (создание, удаление, редактирование)
# ar.registry.editor	✅    ✅    ❌ (только push/pull/удаление артефактов)
# ar.registry.viewer	❌    ✅    ❌ (только просмотр)

# ============================================
# Сервисный аккаунт для CI/CD (GitHub Actions)
# Права: push/pull/управление артефактами
# ============================================

resource "cloudru_evolution_iam_service_account" "ci_cd" {
  name        = "ci-cd-sa"
  description = "Сервисный аккаунт для CI/CD (push образов в реестр)"

  target ={
    project_id = var.project_id
  }
}

resource "cloudru_evolution_iam_access_key" "ci_cd" {
  service_account_id = cloudru_evolution_iam_service_account.ci_cd.id
  description        = "Ключ для GitHub Actions"
  ttl                = "0"
}

# Роль ar.registry.editor — push/pull артефактов
resource "cloudru_evolution_iam_permission" "ci_cd_registry" {
  resource_id = var.project_id
  subject_id  = cloudru_evolution_iam_service_account.ci_cd.id

  role_identifier ={
    role_name = "ar.registry.editor"
  }
}

# ============================================
# Сервисный аккаунт для ВМ (pull образов)
# Права: только pull из реестра
# ============================================

resource "cloudru_evolution_iam_service_account" "vm" {
  name        = "vm-sa"
  description = "Сервисный аккаунт для ВМ (pull образов из реестра)"

  target ={
    project_id = var.project_id
  }
}

resource "cloudru_evolution_iam_access_key" "vm" {
  service_account_id = cloudru_evolution_iam_service_account.vm.id
  description        = "Ключ для ВМ"
  ttl                = 365
}

# Роль ar.registry.viewer — только pull
resource "cloudru_evolution_iam_permission" "vm_registry" {
  resource_id = var.project_id
  subject_id  = cloudru_evolution_iam_service_account.vm.id

  role_identifier ={
    role_name = "ar.registry.viewer"
  }
}

# --- Выводы ---

# ============================================
# Выводы
# ============================================

# CI/CD аккаунт
output "ci_cd_key_id" {
  value       = cloudru_evolution_iam_access_key.ci_cd.key_id
  description = "Key ID для CI/CD (GitHub Actions)"
}
# 4bc74ee768814c29fe6519b41ad5c54c

output "ci_cd_key_secret" {
  value       = cloudru_evolution_iam_access_key.ci_cd.secret
  description = "Key Secret для CI/CD (GitHub Actions)"
  sensitive   = true
}
# 4c92c1a970cc093644c16df8169e5dd7

# ВМ аккаунт
output "vm_key_id" {
  value       = cloudru_evolution_iam_access_key.vm.key_id
  description = "Key ID для ВМ (pull образов)"
}

output "vm_key_secret" {
  value       = cloudru_evolution_iam_access_key.vm.secret
  description = "Key Secret для ВМ (pull образов)"
  sensitive   = true
}

# Реестр
output "registry_uri" {
  value       = "${var.container_registry_name}.cr.cloud.ru"
  description = "URI реестра Docker-образов"
}

# S3 backend
output "s3_access_key" {
  value       = "${var.tenant_id}:${cloudru_evolution_iam_access_key.ci_cd.key_id}"
  description = "Access Key для S3 API (формат tenant_id:key_id)"
  sensitive   = true
}

output "s3_secret_key" {
  value       = cloudru_evolution_iam_access_key.ci_cd.secret
  description = "Secret Key для S3 API"
  sensitive   = true
}



