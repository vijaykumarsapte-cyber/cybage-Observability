variable "location" {
  description = "Azure region where the subnet will be deployed"
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

variable "subnet_name" {
  description = "Name of the Subnet"
  type        = string
}

variable "subnet_address_space" {
  description = "Address prefixes (CIDR blocks) for the subnet"
  type        = list(string)
}

variable "service_endpoints" {
  description = "List of service endpoints to enable on the subnet"
  type        = list(string)
  default     = []
}

variable "delegations" {
  description = "List of delegations for the subnet, each as an object with 'name' and 'service_delegation' keys"
  type = list(object({
    service_delegation = object({
      name    = string
      actions = optional(list(string))
    })
  }))
  default = []
}
