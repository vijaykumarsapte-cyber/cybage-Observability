variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "acr_name" {
  description = "Name of the Azure Container Registry"
  type        = string
}

variable "acr_location" {
  description = "Azure region for the ACR"
  type        = string
}

variable "acr_sku" {
  description = "SKU of the ACR (Basic, Standard, Premium)"
  type        = string
  default     = "Standard"
}

variable "admin_enabled" {
  description = "Enable admin user on ACR"
  type    = bool
  default = false
}

variable "public_network_access_enabled" {
  description = "Whether ACR allows public network access."
  type        = bool
  default     = false
}