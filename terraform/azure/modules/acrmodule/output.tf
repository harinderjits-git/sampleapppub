output "id" {
  value       = local.consumable.id

}

output "login_server" {
  value       = local.consumable.login_server
  description = "The URL that can be used to log into the container registry, formatted as - acr_name.azurecr.io"
}


output "admin_username" {
  value       = local.consumable.admin_username
  description = "The URL that can be used to log into the container registry, formatted as - acr_name.azurecr.io"
}


output "admin_password" {
  value       = local.consumable.admin_password
  sensitive = true
  description = "The URL that can be used to log into the container registry, formatted as - acr_name.azurecr.io"
}
