resource "azurerm_monitor_diagnostic_setting" "aks_diagnostic" {
  name                       = var.diagnostic_settings_name
  target_resource_id         = var.aks_cluster_id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_metric {
    category = "AllMetrics"
  }

  enabled_log {
    category = "kube-apiserver"
 }

  enabled_log {
    category = "kube-audit"
 }

  enabled_log {
    category = "kube-audit-admin"
 }

  enabled_log {
    category = "kube-controller-manager"
 }

  enabled_log {
    category = "kube-scheduler"
  }

  enabled_log {
    category = "cluster-autoscaler"
 }

  enabled_log {
    category = "guard"
 }
}