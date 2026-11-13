# Network Interface (NIC) Module

This module creates an Azure Network Interface (azurerm_network_interface) and one or more IP configurations attached to a subnet.

## Usage

```hcl
module "nic" {
  source              = "./modules/network/nic"
  resource_group_name = "rg-network"         # required
  location            = "eastus"            # required
  nic_name            = "nic-web-01"         # required
  subnet_id           = azurerm_subnet.app.id # required
  private_ip_allocation = "Dynamic"          # optional, default dynamic
  private_ip_address    = null               # optional (use with Static allocation)
  tags                = {}
}
```

## Variables

| Name                | Type   | Description                                                              | Required | Default     |
|---------------------|--------|--------------------------------------------------------------------------|----------|-------------|
| resource_group_name | string | Resource group for the NIC.                                              | Yes      | n/a         |
| location            | string | Azure region for the NIC.                                                | Yes      | "eastus"   |
| nic_name            | string | Name of the network interface.                                           | Yes      | n/a         |
| subnet_id           | string | Resource ID of the subnet to attach the NIC to.                          | Yes      | n/a         |
| private_ip_allocation | string | "Dynamic" or "Static".                                                   | No       | "Dynamic"   |
| private_ip_address  | string | Static IP address (required when allocation is "Static").                | No       | ""          |
| ip_configurations   | list(object) | Optional additional IP configs (name, subnet_id, private_ip_allocation). | No | []          |
| enable_ip_forwarding| bool   | Enable IP forwarding on the NIC.                                         | No       | false       |
| tags                | map    | Tags to apply.                                                            | No       | {}          |

## Outputs

| Name             | Description |
|------------------|-------------|
| nic_id           | Resource ID of the created network interface |
| nic_name         | Name of the created NIC |
| primary_private_ip| Primary private IP address assigned |

## References

- Terraform azurerm_network_interface: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface
- Azure network interface overview: https://learn.microsoft.com/azure/virtual-network/network-interface-overview
- Private IP addressing and allocation: https://learn.microsoft.com/azure/virtual-network/virtual-network-ip-addresses-overview
