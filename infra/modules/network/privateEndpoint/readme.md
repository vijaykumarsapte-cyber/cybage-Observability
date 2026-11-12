# Private Endpoint Module

This module provisions an Azure Private Endpoint (azurerm_private_endpoint) and its private DNS zone configuration for a given target resource.

## Usage

```hcl
module "private_endpoint" {
  source               = "./modules/network/privateEndpoint"
  resource_group_name  = "rg-network"         # required
  location             = "eastus"            # required
  private_endpoint_name= "pe-storage-01"      # required
  subnet_id            = azurerm_subnet.pe.id  # required
  target_resource_id   = azurerm_storage_account.sa.id # required (resource to connect to)
  subresource_names    = ["blob"]             # required (service-specific subresources)
  manual_private_dns_zone = true              # optional: whether module manages DNS zone
}
```

## Variables

| Name                 | Type         | Description                                                                        | Required | Default |
|----------------------|--------------|------------------------------------------------------------------------------------|----------|---------|
| resource_group_name  | string       | Resource group for the private endpoint.                                          | Yes      | n/a     |
| location             | string       | Azure region for the endpoint.                                                     | Yes      | "eastus" |
| private_endpoint_name| string       | Name of the private endpoint.                                                      | Yes      | n/a     |
| subnet_id            | string       | Resource ID of the subnet to place the private endpoint in.                       | Yes      | n/a     |
| target_resource_id   | string       | Resource ID of the target Azure service (storage account, SQL server, etc.).      | Yes      | n/a     |
| subresource_names    | list(string) | List of subresource names to connect (e.g., ["blob","file","sql"]).               | Yes      | n/a     |
| connection_name      | string       | Name used for the private_service_connection block.                                | No       | ""      |
| manual_private_dns_zone | bool      | Whether the module should create/manage the private DNS zone/link.                | No       | false   |
| tags                 | map          | Tags to apply.                                                                     | No       | {}      |

Notes:
- Azure requires subnet_id and target resource details to create a private endpoint.
- subresource_names depend on the target resource type.

## Outputs

| Name                 | Description |
|----------------------|-------------|
| private_endpoint_id  | ID of the created private endpoint |
| network_interfaces   | List of NIC IDs created for the private endpoint |

## References

- Terraform azurerm_private_endpoint: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint
- Terraform azurerm_private_dns_zone_group: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_group
- Azure Private Endpoint and Private Link overview: https://learn.microsoft.com/azure/private-link/private-endpoint-overview
