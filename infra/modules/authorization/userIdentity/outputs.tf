output "identity_id" {
  description = "ID of the user-assigned managed identity."
  value       = azurerm_user_assigned_identity.user_identity.id
}

output "client_id" {
  description = "Client ID of the user-assigned managed identity."
  value       = azurerm_user_assigned_identity.user_identity.client_id
}

output "principal_id" {
  description = "Principal ID of the user-assigned managed identity."
  value       = azurerm_user_assigned_identity.user_identity.principal_id
}
