# AKS Diagnostic Settings Module

This Terraform module creates an Azure Monitor Diagnostic Setting (azurerm_monitor_diagnostic_setting) to send AKS control-plane logs and metrics to a Log Analytics workspace.

## Usage

```hcl
module "aks_diagnostic" {
  source = "./modules/monitoring/diagnosticSetting"

  diagnostic_settings_name   = "aks-diagnostic"
  log_analytics_workspace_id = module.la_workspace.la_workspace_id   # required
  aks_cluster_id             = data.azurerm_kubernetes_cluster.aks.id # required (target resource)
}
```

## Variables

| Name                        | Type   | Description                                                           | Required | Default |
|-----------------------------|--------|-----------------------------------------------------------------------|----------|---------|
| diagnostic_settings_name    | string | Name for the diagnostic setting resource.                             | Yes      | n/a     |
| log_analytics_workspace_id  | string | Resource ID of the Log Analytics workspace to send logs/metrics to.   | Yes      | n/a     |
| aks_cluster_id              | string | Resource ID of the AKS cluster (target_resource_id) to attach to.     | Yes      | n/a     |

Notes:
- azurerm_monitor_diagnostic_setting requires a target resource (aks_cluster_id) and at least one destination (Log Analytics workspace, Event Hub or Storage). This module requires log_analytics_workspace_id.

## Outputs

| Name             | Description                                    |
|------------------|------------------------------------------------|
| aks_diagnostic_ig| ID of the created diagnostic setting resource. |

## Recommendations

- Ensure the Log Analytics workspace exists before applying this module.
- Grant the identity running Terraform sufficient permissions to read the AKS resource and write diagnostic settings (Microsoft.Insights/diagnosticSettings/*).
- Verify required log categories for your AKS version; adjust enabled_log/metric categories if needed.
- Keep workspace and diagnostics naming consistent for easier operations and billing.

## References

- Terraform azurerm_monitor_diagnostic_setting: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting  
- Azure Monitor diagnostic settings overview: https://learn.microsoft.com/azure/monitor/essentials/diagnostic-settings