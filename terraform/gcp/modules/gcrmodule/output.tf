output "id" {
  value       = local.consumable.id

}


output "admin_password" {
  value       = local.consumable.bucket_self_link

}


output "pubkey" {
  value = google_service_account_key.this.public_key_data
  
}

output "privatekey" {
  value = google_service_account_key.this.private_key
  sensitive = true
}