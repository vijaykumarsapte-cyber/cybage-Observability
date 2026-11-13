output "acr_login_server" {
  description = "The login server URL for the ACR"
  value       = azurerm_container_registry.acr.login_server
}

output "acr_admin_username" {
  description = "Admin username if enabled"
  value       = azurerm_container_registry.acr.admin_username
  sensitive   = true
  # Note: Terraform does not support conditional outputs, so this will always output.
}

output "acr_admin_password" {
  description = "Admin password if enabled"
  value       = azurerm_container_registry.acr.admin_password
  sensitive   = true
  # Same note as above about conditional output.
}

output "acr_id" {
  description = "The resource ID for the ACR"
  value       = azurerm_container_registry.acr.id
}