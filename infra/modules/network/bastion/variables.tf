variable "location" {
  description = "Azure region where the private endpoint will be deployed"
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
}

variable "bastion_host_sku" {
  description = "SKU for the Azure Bastion host (for example: Standard)"
  type        = string
  default     = "Standard"
}

variable "bastion_subnet_id" {
  description = "Resource ID of the AzureBastionSubnet to attach the Bastion host to"
  type        = string
}

variable "enable_tunneling" {
  description = "Enable tunneling for the Bastion host to provide RDP/SSH access over TLS (Native Client Support), requires Standard or Premium SKU"
  type        = bool
  default     = false
}
