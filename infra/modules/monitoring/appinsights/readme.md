# Application Insights Module

This Terraform module provisions an Azure Application Insights resource (azurerm_application_insights) for application telemetry and monitoring. It supports optional integration with a Log Analytics workspace and common configuration such as application type, retention, and sampling.

## Usage

```hcl
module "appinsights" {
  source              = "./modules/monitoring/appinsights"

  # Required
  resource_group_name = "rg-monitoring"      # required
  location            = "eastus"            # required (Azure requires a location)
  app_insights_name   = "ai-myapp-prod"      # required
  application_type    = "web"                # required (e.g., "web", "other")

  # Optional
  workspace_id        = null                 # optional: Log Analytics workspace resource ID to link (for workspace-based ingestion)
  retention_in_days   = 90                   # optional: data retention
  sampling_percentage = 100                  # optional: 0-100
  ingress_environment = "Production"         # optional custom tag/property depending on module
  tags                = {}
}
```

## Variables

| Name                | Type         | Description                                                                                     | Required | Default |
|---------------------|--------------|-------------------------------------------------------------------------------------------------|----------|---------|
| resource_group_name | string       | Name of the resource group where Application Insights will be created. Azure requires a resource group. | Yes      | n/a     |
| location            | string       | Azure region where the resource will be created. Azure requires a location.                    | Yes      | n/a     |
| app_insights_name   | string       | Name of the Application Insights resource.                                                      | Yes      | n/a     |
| application_type    | string       | Application type for Insights (e.g., "web", "other"). Required by the resource.                 | Yes      | n/a     |
| workspace_id        | string       | Optional Log Analytics workspace resource ID to link Application Insights to (for workspace-based ingestion). | No | null |
| retention_in_days   | number       | Data retention in days for the resource.                                                         | No       | 90      |
| sampling_percentage | number       | Sampling percentage for telemetry (0-100).                                                      | No       | 100     |
| tags                | map          | Tags to apply to the resource.                                                                   | No       | {}      |

Notes:
- resource_group_name, location, app_insights_name and application_type are required by the Azure Application Insights resource and must be provided.
- If workspace-based ingestion is desired, provide workspace_id. If not provided, the classic instrumentation key/ingestion model is used.

## Outputs

| Name                   | Description |
|------------------------|-------------|
| app_insights_id        | ID of the created Application Insights resource (azurerm_application_insights.*.id) |
| instrumentation_key    | Instrumentation Key for classic ingestion (azurerm_application_insights.*.instrumentation_key) |
| connection_string      | Connection string for SDKs (azurerm_application_insights.*.connection_string) |
| app_id                 | Application Insights App ID (azurerm_application_insights.*.app_id) |
| resource_name          | Name of the created Application Insights resource |

## Recommendations

- Prefer workspace-based ingestion (linking to a Log Analytics workspace) for unified telemetry and retention management.
- Do not expose instrumentation keys or connection strings in source code or public repos; treat them as sensitive.
- Ensure the identity running Terraform has Microsoft.Insights/* and Microsoft.OperationalInsights/* permissions where workspace linking is used.

## References

- Terraform azurerm_application_insights: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights
- Azure Application Insights overview: https://learn.microsoft.com/azure/azure-monitor/app/app-insights-overview
- Application Insights workspace-based ingestion: https://learn.microsoft.com/azure/azure-monitor/app/v2-migrate-workspace