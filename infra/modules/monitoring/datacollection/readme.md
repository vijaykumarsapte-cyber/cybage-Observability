# Data Collection Endpoint (DCE) & Data Collection Rule (DCR) Module

This Terraform module provisions:
- azurerm_monitor_data_collection_endpoint (DCE) — endpoint used by Azure Monitor Agent and other ingestion sources.
- azurerm_monitor_data_collection_rule (DCR) — rules that define data flows, data sources and destinations.
- azurerm_monitor_data_collection_rule_association — associates a DCR with a target resource (e.g., AKS).

Use this module to centralise data ingestion and route telemetry to Log Analytics, Monitor Accounts, or other supported destinations.

## Usage

```hcl
module "datacollection" {
  source              = "./modules/monitoring/datacollection"

  # Required
  dce_name            = "dce-poc-prod"
  dcr_name            = "dcr-poc-prod"
  resource_group_name = "rg-monitoring"
  location            = "eastus"
  target_resource_id  = " /subscriptions/0000-0000-.../resourceGroups/rg-aks/providers/Microsoft.ContainerService/managedClusters/aks-cluster"

  data_flows = [
    {
      streams      = ["Microsoft-InsightsMetrics", "Microsoft-Syslog"]
      destinations = ["la"]
    }
  ]

  data_sources = [
    {
      prometheus_forwarder = {
        name    = "prom-fwd"
        streams = ["Prometheus"]
      }
    },
    {
      extensions = [
        {
          name           = "containerinsights"
          streams        = ["ContainerLog","Metrics"]
          extension_name = "OmsAgentForLinux"
        }
      ]
    }
  ]

  destinations = [
    {
      log_analytics = {
        name                  = "la"
        workspace_resource_id = "/subscriptions/0000-0000-.../resourceGroups/rg-monitoring/providers/Microsoft.OperationalInsights/workspaces/la-poc-prod"
      }
    }
  ]
}
```

## Variables

All variables below are defined in variables.tf and are required by the Azure resources (no default values provided in the module):

| Name                 | Type | Description |
|----------------------|------|-------------|
| dce_name             | string | Name of the Data Collection Endpoint (DCE). Required. |
| dcr_name             | string | Name of the Data Collection Rule (DCR). Required. |
| location             | string | Azure region for DCE & DCR. Required. |
| resource_group_name  | string | Resource group for DCE & DCR. Required. |
| target_resource_id   | string | Target resource ID to associate the DCR with (e.g., AKS cluster resource ID). Required. |
| data_flows           | list(object({ streams = list(string), destinations = list(string) })) | List of data flows mapping streams to destination names. Required. |
| data_sources         | list(object({ prometheus_forwarder = optional(object({ name = string, streams = list(string) })), extensions = optional(list(object({ name = string, streams = list(string), extension_name = string }))) })) | Data sources configuration (Prometheus forwarder and/or extensions). Required (can be empty list if not used). |
| destinations         | list(object({ monitor_account = optional(object({ name = string, monitor_account_id = string })), log_analytics = optional(object({ name = string, workspace_resource_id = string })) })) | Destination targets (Monitor Account or Log Analytics). Required (can be empty list if not used). |

Notes:
- Provide valid Azure resource IDs for target_resource_id and workspace_resource_id fields.
- Data source/destination objects use optional fields; include only the blocks you need per element.
- Azure requires resource_group_name and location for these resources.

## Outputs

| Name | Description |
|------|-------------|
| dce_id | Resource ID of the created Data Collection Endpoint (azurerm_monitor_data_collection_endpoint.dce.id) |
| dcr_id | Resource ID of the created Data Collection Rule (azurerm_monitor_data_collection_rule.dcr.id) |
| dcr_association_id | Resource ID of the Data Collection Rule association with the target resource (azurerm_monitor_data_collection_rule_association.dcr_assoc.id) |

## Recommendations

- Ensure the Log Analytics workspace or Monitor Account destinations exist before applying the module (use data sources or module references).
- Validate stream names and supported destinations per Azure DCR documentation (stream names and subresources vary by source).
- Use least-privilege permissions for the identity applying Terraform (needs rights to create monitor resources and to associate rules with target resources).
- Test DCR configurations in a non-production environment before applying to production clusters.
- Keep naming consistent to make data_flow destination references predictable (destination "name" fields are used in data_flow.destinations).

## References

- Terraform azurerm_monitor_data_collection_endpoint: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_data_collection_endpoint
- Terraform azurerm_monitor_data_collection_rule: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_data_collection_rule
- Terraform azurerm_monitor_data_collection_rule_association: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_data_collection_rule_association
- Azure Monitor Data Collection Rules overview: https://learn.microsoft.com/azure/azure-monitor/agents/data-collection-rule-overview