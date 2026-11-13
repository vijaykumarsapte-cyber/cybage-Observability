variable "location" {
  description = "Azure region where the Virtual Network will be deployed"
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "vnet_name" {
  description = "Name of the Virtual Network"
  type        = string
}

variable "vnet_address_space" {
  description = "List of address spaces (CIDR ranges) for the Virtual Network"
  type        = list(string)
}

variable "private_endpoint_name" {
  description = "The name of the private endpoint"
  type        = string
  default     = "pe-poc-kv-qa"
}

variable "private_service_connection_name" {
  description = "The name of the private service connection"
  type        = string
  default     = "kv-pe-connection"
}

variable "subnet_id" {
  description = "The ID of the subnet to associate with the private endpoint"
  type        = string
}
