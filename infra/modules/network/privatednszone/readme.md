# Private DNS Zone Module

This module provisions an Azure Private DNS Zone (azurerm_private_dns_zone) and optional virtual network links and record sets.

## Usage

```hcl
module "private_dns" {
  source              = "./modules/network/privatednszone"
  resource_group_name = "rg-network"         # required
  zone_name           = "privatelink.database.windows.net" # required
  tags                = {}
  virtual_network_links = [
    { name = "vnet-link", virtual_network_id = data.azurerm_virtual_network.vnet.id, registration_enabled = false }
  ]
}
```

## Variables

| Name                | Type         | Description                                                                      | Required | Default |
|---------------------|--------------|----------------------------------------------------------------------------------|----------|---------|
| resource_group_name | string       | Resource group for the private DNS zone.                                        | Yes      | n/a     |
| zone_name           | string       | DNS zone name (e.g., privatelink.mysql.database.azure.com).                      | Yes      | n/a     |
| tags                | map          | Tags to apply.                                                                   | No       | {}      |
| virtual_network_links | list(object)| Optional list of virtual network link objects: { name, virtual_network_id, registration_enabled } | No | [] |
| records             | list(object) | Optional DNS records to create (A, CNAME, PTR, etc).                            | No       | []      |

Notes:
- Private DNS Zones are not regional but require a resource group; resource_group_name is required by Azure resources.

## Outputs

| Name            | Description |
|-----------------|-------------|
| private_dns_zone_id | Resource ID of the created private DNS zone |
| private_dns_zone_name | Name of the created DNS zone |

## References

- Terraform azurerm_private_dns_zone: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone
- Terraform azurerm_private_dns_zone_virtual_network_link: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link
- Azure Private DNS overview: https://learn.microsoft.com/azure/dns/private-dns-overview
