# Azure Monitor Workspace Module

This Terraform module provisions an Azure Monitor Workspace (azurerm_monitor_workspace) used for storing and querying monitoring telemetry. Use this when you need a centralized Azure Monitor workspace distinct from the classic Log Analytics workspace resource.

## Usage

```hcl
module "azmonitor" {
  source                    = "./modules/monitoring/azmonitorworkspace"

  # Required
  resource_group_name       = "rg-monitoring"         # required
  location                  = "eastus"               # required (Azure requires a location)
  azmonitor_workspace_name  = "amw-poc-prod"          # required

  # Optional
  public_network_access     = true                    # default: true
  tags                      = {}
}

output "azmonitor_workspace_id" {
  value = module.azmonitor.azmonitor_workspace_id
}
```

## Variables

| Name                     | Type   | Description                                                                                          | Required | Default   |
|--------------------------|--------|------------------------------------------------------------------------------------------------------|----------|-----------|
| resource_group_name      | string | Name of the resource group where the Azure Monitor Workspace will be created.                       | Yes      | n/a       |
| location                 | string | Azure region for the workspace. Azure requires a location for regional resources.                   | Yes      | "eastus" |
| azmonitor_workspace_name | string | Name of the Azure Monitor Workspace resource.                                                        | Yes      | n/a       |
| public_network_access    | bool   | Enable or disable public network access to the workspace (true = enabled).                           | No       | true      |

Notes:
- Although the module provides a default for `location`, the Azure resource requires an explicit location; the variable is marked as required to ensure the caller intentionally provides or accepts the default.
- `resource_group_name` and `azmonitor_workspace_name` must be supplied.

## Outputs

| Name                   | Description                                                                 |
|------------------------|-----------------------------------------------------------------------------|
| azmonitor_workspace_id | Azure Monitor workspace ID (azurerm_monitor_workspace.azmonitor.id)        |

## Recommendations

- Ensure the identity running Terraform has the necessary permissions (e.g., Microsoft.Insights/* and relevant RBAC) in the target subscription/resource group.
- If restricting network access, plan for private endpoints and DNS configuration for services that need to send telemetry.
- Treat workspace identifiers and keys as sensitive; do not hard-code them in public repositories.

## References

- Terraform azurerm_monitor_workspace: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_workspace
- Azure Monitor overview: https://learn.microsoft.com/azure/azure-monitor/overview
- Azure Monitor workspace networking and access (Private Link): https://learn.microsoft.com/azure/azure-monitor/essentials/private-link