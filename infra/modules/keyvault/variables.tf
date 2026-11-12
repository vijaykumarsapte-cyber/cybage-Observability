variable "location" {
  description = "Location for the resources."
  type        = string
  default     = "eastus"
}

variable "subscription_id" {
  description = "Subscription ID."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
}

variable "keyvault_name" {
  description = "Name of KeyVault"
  type        = string
}

variable "keyvault_sku_name" {
  description = "SKU of KeyVault"
  type        = string
  default     = "standard"
  validation {
    condition     = contains(["standard", "premium"], lower(var.keyvault_sku_name))
    error_message = "Key Vault SKU must be either 'standard' or 'premium'."
  }
}

variable "enable_purge_protection" {
  description = "Enable purge protection for the Key Vault."
  type        = bool
  default     = false
}

variable "enable_rbac_authorization" {
  description = "Enable RBAC authorization for the Key Vault."
  type        = bool
  default     = false
}

variable "soft_delete_retention_days" {
  description = "Number of days to retain soft-deleted Key Vaults."
  type        = number
  default     = 7
}

variable "ip_whitelist" {
  description = "List of IP addresses allowed to access the Key Vault."
  type        = list(string)
  default     = ["x.x.x.x/32"]
}

variable "public_network" {
  description = "Allow public network access to the Key Vault."
  type        = bool
  default     = true
}

# variable "secret_name" {
#   description = "Name of the Key Vault secret."
#   type        = string
#   default     = "tfmigration"
# }

# variable "secret_value" {
#   description = "Value of the Key Vault secret."
#   type        = string
#   sensitive   = true
# }

# For network ACL
variable "subnet_names" {
  description = "Names of subnets to include."
  type        = list(string)
  default     = []
}

locals {
  vnet_id = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.Network/virtualNetworks/poc_VNET"

  subnet_ids = [
    for name in var.subnet_names :
    "${local.vnet_id}/subnets/${name}"
  ]
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID for the private endpoint."
  type        = string
  default     = null
}

variable "private_endpoint_name" {
  description = "Name of the Key Vault private endpoint."
  type        = string
}