# Log Analytics Workspace (LA Workspace) Module

This Terraform module provisions an Azure Log Analytics workspace (azurerm_log_analytics_workspace) for collecting and analysing telemetry across Azure services. The module creates a workspace with SKU PerGB2018 and a 30-day retention by default (as implemented in the module).

## Usage

```hcl
module "la_workspace" {
  source                       = "./modules/monitoring/laworkspace"

  # Required
  resource_group_name          = "rg-monitoring"            # required
  location                     = "eastus"                  # required (Azure requires a location)
  log_analytics_workspace_name = "la-poc-prod"              # required

  # No other variables are exposed by this module (SKU and retention are set in module)
}

output "la_workspace_id" {
  value = module.la_workspace.la_workspace_id
}
```

## Variables

| Name                         | Type   | Description                                                              | Required | Default   |
|------------------------------|--------|--------------------------------------------------------------------------|----------|-----------|
| resource_group_name          | string | Name of the resource group where the Log Analytics workspace will be created. | Yes      | n/a       |
| location                     | string | Azure region for the workspace (Azure requires a location).              | Yes      | "eastus" |
| log_analytics_workspace_name | string | Name of the Log Analytics Workspace                                       | Yes      | n/a       |

Notes:
- The Azure resource requires a resource group and a location; these variables are marked required to ensure the caller intentionally provides or accepts defaults.
- SKU and retention are currently fixed in the module implementation (PerGB2018, 30 days).

## Outputs

| Name           | Description                                                                 |
|----------------|-----------------------------------------------------------------------------|
| la_workspace_id| Log Analytics workspace ID (azurerm_log_analytics_workspace.log_analytics.id)|

## Recommendations

- Ensure the identity running Terraform has Microsoft.OperationalInsights/* permissions in the target subscription/resource group.
- Consider adjusting SKU and retention in a forked module if your environment needs different pricing/retention settings.
- Treat workspace keys and any sensitive telemetry endpoints as secrets; do not commit them to public repositories.
- Use workspace-level tags and RBAC to manage access and billing attribution.

## References

- Terraform azurerm_log_analytics_workspace: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace  
- Azure Monitor / Log Analytics overview: https://learn.microsoft.com/azure/azure-monitor/logs/log-analytics-overview  
- Log Analytics pricing and data caps: https://learn.microsoft.com/azure/azure-monitor/pricing