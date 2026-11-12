output "application_gateway_id" {
  description = "Application Gateway ID"
  value       = azurerm_application_gateway.this.id
}

output "public_ip_address" {
  description = "Public IP address of the Application Gateway"
  value       = azurerm_public_ip.this.ip_address
}