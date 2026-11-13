# Virtual Network (VNet) Module

This module provisions an Azure Virtual Network (azurerm_virtual_network) with address space, optional DNS servers, and optionally creates subnets.

## Usage

```hcl
module "vnet" {
  source              = "./modules/network/vnet"
  resource_group_name = "rg-network"         # required
  location            = "eastus"            # required
  vnet_name           = "vnet-poc"           # required
  address_space       = ["10.0.0.0/16"]      # required
  dns_servers         = []                   # optional
  subnets = [
    { name = "subnet-app", prefix = "10.0.1.0/24" },
    { name = "subnet-db", prefix  = "10.0.2.0/24" }
  ]
  tags = {}
}
```

## Variables

| Name                | Type         | Description                                                              | Required | Default |
|---------------------|--------------|--------------------------------------------------------------------------|----------|---------|
| resource_group_name | string       | Resource group to create the virtual network in.                         | Yes      | n/a     |
| location            | string       | Azure region for the virtual network.                                    | Yes      | "eastus" |
| vnet_name           | string       | Name of the virtual network.                                              | Yes      | n/a     |
| address_space       | list(string) | Address space for the VNet (e.g., ["10.0.0.0/16"]).                       | Yes      | n/a     |
| dns_servers         | list(string) | Optional custom DNS servers.                                              | No       | []      |
| subnets             | list(object) | Optional list of subnet objects: { name, prefix, service_endpoints?, delegations? } | No | [] |
| tags                | map          | Tags to apply to the VNet.                                                 | No       | {}      |

Notes:
- resource_group_name, location, vnet_name, and address_space are required by Azure to create a virtual network.
- Subnet creation may be delegated to the subnet module if desired.

## Outputs

| Name              | Description |
|-------------------|-------------|
| vnet_id           | Resource ID of the virtual network |
| vnet_name         | Name of the virtual network |
| address_space     | Address space assigned to the VNet |
| subnet_ids        | Map of subnet names to their resource IDs (if subnets created by module) |

## References

- Terraform azurerm_virtual_network: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network
- Azure virtual network overview: https://learn.microsoft.com/azure/virtual-network/virtual-networks-overview
- Azure DNS servers and address space guidance: https://learn.microsoft.com/azure/virtual-network/virtual-network-manage-dns
