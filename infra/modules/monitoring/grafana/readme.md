# Grafana Module

This module provisions an Azure Grafana instance (azurerm_dashboard_grafana) with a system-assigned managed identity, optional managed private endpoint to an Azure Monitor workspace, and role assignments for Grafana admins/readers/editors.

### Example usage

```hcl
module "grafana" {
  source                    = "./modules/monitoring/grafana"

  # Required
  resource_group_name       = "rg-monitoring"
  location                = "eastus"
  grafana_name              = "poc-grafana"
  azmonitor_workspace_id    = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.OperationalInsights/workspaces/<workspace>"
  log_analytics_workspace_id= "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.OperationalInsights/workspaces/<workspace>"

  # Optional
  # grafana_sku             = "Standard"
  # grafana_version         = "11"
  # grafana_admins          = []
  # grafana_readers         = []
  # grafana_editors         = []
  # create_managed_pe       = false
}
```

---

### Variables

| Name                       | Type         | Description                                                                                | Required | Default   |
|----------------------------|--------------|--------------------------------------------------------------------------------------------|----------|-----------|
| location                   | string       | Azure region for the Grafana resource                                                      | Yes      | "eastus" |
| resource_group_name        | string       | Name of the resource group                                                                 | Yes      | n/a       |
| grafana_name               | string       | Name of the Grafana instance                                                               | Yes      | n/a       |
| grafana_sku                | string       | Grafana SKU for azurerm_dashboard_grafana                                                  | Yes      | "Standard"|
| grafana_version            | string       | Grafana major version for azurerm_dashboard_grafana                                        | No       | "11"      |
| azmonitor_workspace_id     | string       | Azure Monitor / Log Analytics workspace resource ID to integrate with Grafana              | Yes      | n/a       |
| log_analytics_workspace_id | string       | Log Analytics workspace resource ID (used for role assignment)                             | Yes      | n/a       |
| grafana_admins             | list(string) | List of AAD Service Principal object IDs to grant Grafana Admin role                       | Yes      | []        |
| grafana_readers            | list(string) | List of AAD Service Principal object IDs to grant Grafana Reader role                      | Yes      | []        |
| grafana_editors            | list(string) | List of AAD Service Principal object IDs to grant Grafana Editor role                      | Yes      | []        |
| create_managed_pe          | bool         | Whether to create a managed private endpoint for Grafana to connect to Azure Monitor / DCE | No       | false     |

---

### Outputs

| Name                          | Description |
|-------------------------------|-------------|
| grafana_instance_id           | Resource ID of the created Grafana instance (azurerm_dashboard_grafana.grafana.id) |
| grafana_instance_url          | Endpoint/URL of the Grafana instance (provider-specific attribute) |
| grafana_identity_principal_id | Principal (object) ID of Grafana's system-assigned managed identity |
| grafana_managed_pe_id         | ID of the created managed private endpoint (azurerm_dashboard_grafana_managed_private_endpoint), if created |

---


### Notes & recommendations
- The module assigns "Monitoring Data Reader" and "Log Analytics Reader" roles to the Grafana managed identity and creates role assignments for lists provided in grafana_admins / grafana_readers / grafana_editors.
- If create_managed_pe = true the module creates a managed private endpoint to the configured azmonitor_workspace_id; ensure necessary networking and private endpoint approvals are handled.
- Avoid committing secrets; provide sensitive info via Key Vault or CI secret store.

### References
- Azure Grafana: https://learn.microsoft.com/azure/managed-grafana/overview  
- Azure Monitor / Log Analytics: https://learn.microsoft.com/azure/azure-monitor/overview
```// filepath: e:\Projects\cybage\Code\poc-infra\modules\monitoring\grafana\readme.md
