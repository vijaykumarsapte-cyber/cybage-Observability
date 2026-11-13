## Azure Container Registry (ACR) Module

This module provisions an Azure Container Registry with optional admin access.

### Example Usage

```hcl
module "container_registry" {
  source              = "./modules/acr"
  acr_name            = "myacrname"
  resource_group_name = "my-resource-group"
  acr_location        = "eastus"
  acr_sku             = "Standard"
  admin_enabled       = true
}
```

### Variables

| Name                | Type      | Description                                 | Required | Default    |
|---------------------|-----------|---------------------------------------------|----------|------------|
| acr_name            | string    | Name of the Azure Container Registry        | Yes      | n/a        |
| resource_group_name | string    | Name of the resource group                  | Yes      | n/a        |
| acr_location        | string    | Azure region for the ACR                    | Yes      | n/a        |
| acr_sku             | string    | SKU of the ACR (Basic, Standard, Premium)   | No       | "Standard" |
| admin_enabled       | bool      | Enable admin user on ACR                    | No       | false      |

### Outputs

| Name               | Description                              |
|--------------------|------------------------------------------|
| acr_login_server   | The login server URL for the ACR         |
| acr_admin_username | Admin username if enabled                |
| acr_admin_password | Admin password if enabled                |
| acr_id             | The resource ID for the ACR              |

See [modules/acr/main.tf](modules/acr/main.tf), [modules/acr/variables.tf](modules/acr/variables.tf), and [modules/acr/outputs.tf](modules/acr/outputs.tf) for implementation details.