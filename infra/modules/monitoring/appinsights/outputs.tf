output "app_insights_instrumentation_key" {
  description = "Instrumentation key of the Application Insights."
  value       = azurerm_application_insights.app_insights.instrumentation_key
  sensitive   = true
}

output "app_insights_app_id" {
  description = "Application ID of the Application Insights."
  value       = azurerm_application_insights.app_insights.app_id
  sensitive   = true
}

output "app_insights_id" {
  description = "Resource ID of the Application Insights."
  value       = azurerm_application_insights.app_insights.id
}

output "app_insights_connection_string" {
  description = "Connection string of the Application Insights."
  value       = azurerm_application_insights.app_insights.connection_string
}
