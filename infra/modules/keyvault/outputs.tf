output "keyvault_id" {
  description = "ID of the Key Vault."
  value       = azurerm_key_vault.keyvault.id
}

output "keyvault_uri" {
  description = "URI of the Key Vault."
  value       = "https://${var.keyvault_name}.vault.azure.net/"
}

# output "private_endpoint_id" {
#   description = "ID of the private endpoint for the Key Vault."
#   value       = azurerm_private_endpoint.kv_pe.id
# }
