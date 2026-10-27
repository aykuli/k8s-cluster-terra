# @note Provider instruction 
#       https://cloud.ru/docs/terraform-evolution/ug/topics/guides/vm_create_full?source-platform=Evolution
terraform {
  required_providers {
    cloudru = {
      source  = "cloudru/cloud"
      version = "2.1.4"
    }
  }
  required_version = ">= 1.3.0"
}

provider "cloudru" {
  project_id  = var.project_id
  auth_key_id = var.auth_key_id
  auth_secret = var.auth_secret
  object_storage_tenant_id  = var.tenant_id
}
