variable "location" {
  description = "Azure region where the virtual network will be deployed"
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "nic_name" {
  description = "Name of the NIC"
  type        = string
}

variable "subnet_id" {
  description = "ID of the Subnet"
  type        = string
}
