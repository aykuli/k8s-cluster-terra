resource "yandex_storage_bucket" "tf_state" {
  bucket    = var.bucket.name
  folder_id = var.folder_id
  max_size  = var.bucket.size

  access_key = yandex_iam_service_account_static_access_key.diploma_sa_static_key.access_key
  secret_key = yandex_iam_service_account_static_access_key.diploma_sa_static_key.secret_key
  
  versioning { enabled = true }
}