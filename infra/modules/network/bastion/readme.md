# Azure Bastion Module

This module provisions an Azure Bastion Host (azurerm_bastion_host) and its required public IP configuration to provide secure RDP/SSH access to VMs without exposing them to the internet.

## Usage

```hcl
module "bastion" {
  source             = "./modules/network/bastion"
  resource_group_name = "rg-network"         # required
  location            = "eastus"            # required
  bastion_name        = "bastion-poc"        # required
  subnet_id           = data.azurerm_subnet.bastion.id  # required (must be the AzureBastionSubnet)
  public_ip_id        = azurerm_public_ip.bastion_ip.id # required
}
```

## Variables

| Name                | Type   | Description                                                                 | Required | Default |
|---------------------|--------|-----------------------------------------------------------------------------|----------|---------|
| resource_group_name | string | Resource group where the Bastion and its resources will be created.         | Yes      | n/a     |
| location            | string | Azure region for the Bastion host.                                          | Yes      | "eastus" |
| bastion_name        | string | Name for the bastion host resource.                                         | Yes      | n/a     |
| subnet_id           | string | Resource ID of the subnet to attach the Bastion to (must be AzureBastionSubnet). | Yes  | n/a     |
| public_ip_id        | string | Resource ID of the public IP to associate with Bastion (or module may create one). | Yes | n/a     |
| tags                | map    | Optional tags to apply.                                                     | No       | {}      |

Notes:
- Azure requires a dedicated subnet named "AzureBastionSubnet" with /26 or larger prefix; provide its resource ID via subnet_id.
- resource_group_name and location are required by Azure even if defaults exist.

## Outputs

| Name             | Description |
|------------------|-------------|
| bastion_id       | ID of the created azurerm_bastion_host resource |
| bastion_name     | Name of the created Bastion host |
| bastion_ip_id    | ID of the associated public IP (if created/exposed) |

## References

- Terraform azurerm_bastion_host: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/bastion_host
- Azure Bastion overview: https://learn.microsoft.com/azure/bastion/
- Azure Public IP (when creating Bastion public IP): https://learn.microsoft.com/azure/virtual-network/public-ip-address
