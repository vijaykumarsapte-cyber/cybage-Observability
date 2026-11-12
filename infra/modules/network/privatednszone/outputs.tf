output "private_dns_zone_id" {
  description = "ID of the created Private DNS Zone"
  value       = azurerm_private_dns_zone.private_dns_zone.id
}

output "private_dns_zone_name" {
  description = "Name of the Private DNS Zone"
  value       = azurerm_private_dns_zone.private_dns_zone.name
}
