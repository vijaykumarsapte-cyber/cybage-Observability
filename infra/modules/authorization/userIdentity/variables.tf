variable "resource_group_name" {
  type        = string
  description = "Name of the existing resource group"
}

variable "location" {
  type        = string
  default     = "eastus"
  description = "Azure region"
}

variable "identity_name" {
  type        = string
  description = "Name of the user-assigned managed identity"
}

variable "common_tags" {
  type = map(string)
}