# Subnet Module

This module creates an Azure Subnet (azurerm_subnet) within an existing virtual network and optional delegations, service endpoints, and network security group association.

## Usage

```hcl
module "subnet" {
  source              = "./modules/network/subnet"
  resource_group_name = "rg-network"         # required
  virtual_network_name= "vnet-poc"           # required (or provide virtual_network_id if module supports)
  subnet_name         = "app-subnet"         # required
  address_prefixes    = ["10.0.2.0/24"]      # required
  service_endpoints   = ["Microsoft.Storage"] # optional
  delegations         = []                   # optional
  network_security_group_id = azurerm_network_security_group.nsg.id # optional
}
```

## Variables

| Name                   | Type         | Description                                                               | Required | Default |
|------------------------|--------------|---------------------------------------------------------------------------|----------|---------|
| resource_group_name    | string       | Resource group containing the virtual network.                            | Yes      | n/a     |
| virtual_network_name   | string       | Name of the virtual network to attach the subnet to (or provide vnet_id). | Yes      | n/a     |
| subnet_name            | string       | Name of the subnet.                                                        | Yes      | n/a     |
| address_prefixes       | list(string) | CIDR prefixes for the subnet (e.g., ["10.0.2.0/24"]).                      | Yes      | n/a     |
| service_endpoints      | list(string) | Service endpoints to enable (e.g., ["Microsoft.Storage"]).                | No       | []      |
| delegations            | list(object) | Subnet delegations (name, service_delegation).                             | No       | []      |
| network_security_group_id | string    | Network security group resource ID to associate with the subnet.           | No       | ""      |
| enforce_private_link_endpoint_network_policies | bool | Toggle PL endpoint network policies as needed per workload.        | No       | true    |
| tags                   | map          | Tags to apply.                                                              | No       | {}      |

Notes:
- virtual_network_name and resource_group_name are required by azurerm_subnet in typical module implementations.
- address_prefixes are required to create a subnet.

## Outputs

| Name             | Description |
|------------------|-------------|
| subnet_id        | ID of the created subnet |
| subnet_name      | Name of the created subnet |
| address_prefixes | The CIDR prefixes assigned to the subnet |

## References

- Terraform azurerm_subnet: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet
- Azure subnet and delegation guidance: https://learn.microsoft.com/azure/virtual-network/subnet-overview
- Service endpoints and delegation: https://learn.microsoft.com/azure/virtual-network/virtual-network-service-endpoints-overview
