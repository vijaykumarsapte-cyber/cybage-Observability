output "subnet_name" {
  description = "The name of the Subnet"
  value       = azurerm_subnet.subnet.name
}

output "subnet_id" {
  description = "The ID of the Subnet"
  value       = azurerm_subnet.subnet.id
}
