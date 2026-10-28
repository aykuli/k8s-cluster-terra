# @note DOC RESOURCE: https://cloud.ru/docs/terraform-evolution/ug/topics/guides/vm_create_full?source-platform=Evolution
terraform {
  backend "s3" {
    endpoints  = { s3 = "https://s3.cloud.ru" }
    bucket     = "diploma-tfstate-cloudru"
    key        = "k8s-cluster/terraform.tfstate"

    region                      = "ru-central-1"
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }

  required_version = ">= 1.3.0"
}
