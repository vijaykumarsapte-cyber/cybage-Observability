output "aks_diagnostic_ig" {
  description = "Diagnostic settings ID"
  value       = azurerm_monitor_diagnostic_setting.aks_diagnostic.id
}
