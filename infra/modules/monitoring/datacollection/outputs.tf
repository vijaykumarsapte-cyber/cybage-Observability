output "dce_id" {
  value       = azurerm_monitor_data_collection_endpoint.dce.id
  description = "Resource ID of the created Data Collection Endpoint."
}

output "dcr_id" {
  value       = azurerm_monitor_data_collection_rule.dcr.id
  description = "Resource ID of the created Data Collection Rule."
}

output "dcr_association_id" {
  value       = azurerm_monitor_data_collection_rule_association.dcr_assoc.id
  description = "Resource ID of the DCR association with the target resource (AKS)."
}
