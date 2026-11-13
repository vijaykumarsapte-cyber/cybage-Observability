output "grafana_instance_id" {
  description = "The ID of the Grafana instance"
  value       = azurerm_dashboard_grafana.grafana.id
}

output "grafana_instance_url" {
  description = "The URL of the Grafana instance"
  value       = azurerm_dashboard_grafana.grafana.endpoint
}

output "grafana_identity_principal_id" {
  description = "The principal ID of the Grafana instance's managed identity"
  value       = azurerm_dashboard_grafana.grafana.identity[0].principal_id
}