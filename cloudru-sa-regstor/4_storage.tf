# ============================================
# Бакет Object Storage (Terraform state)
# ============================================
resource "cloudru_evolution_obs_bucket" "tf_state" {
  bucket     = var.bucket.name
  versioning = true

  storage_class = "STANDARD"

  tags = [
    { key = "purpose", value = "terraform-state" },
    { key = "owner",   value = "diploma_sa" }
  ]
  quota         = var.bucket.size
  quota_unit    =  var.bucket.unit
  quota_type    =  var.bucket.type
}

output "bucket_name" {
  value       = cloudru_evolution_obs_bucket.tf_state.id
  description = "Имя созданного бакета"
}