# # @note DOC RESOURCE: https://yandex.cloud/ru/docs/tutorials/infrastructure-management/terraform-state-storage
terraform {
  backend "s3" {
    endpoints  = { s3 = "https://storage.yandexcloud.net" }
    bucket     = "diploma-tfstate"
    key        = "diploma/terraform.tfstate"

    region                      = "ru-central1"
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true # Необходимая опция Terraform для версии 1.6.1 и старше.
    skip_s3_checksum            = true # Необходимая опция при описании бэкенда для Terraform версии 1.6.3 и старше.
  }

  required_version = ">= 1.3.0"
}

# terraform {
#   backend "s3" {
#     bucket       = "terraform-state-myproject"
#     key          = "terraform/state.tfstate"
#     region       = "ru-central-1"
#     endpoint     = "https://s3.cloud.ru"
#     access_key   = "ваш-tenant_id:ваш-key_id"
#     secret_key   = "ваш-secret"
#     skip_credentials_validation = true
#     skip_metadata_api_check     = true
#     skip_requesting_account_id  = true
#   }

#   required_providers {
#     cloudru = {
#       source  = "cloud.ru/cloudru/cloud"
#       version = ">= 2.0.0"
#     }
#   }
# }
