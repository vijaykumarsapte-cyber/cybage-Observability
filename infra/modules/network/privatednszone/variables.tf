variable "location" {
  description = "Azure region where the private endpoint will be deployed"
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "private_dns_zone" {
  description = "Name of the private DNS zone (e.g. privatelink.eastus.azmk8s.io)"
  type        = string
}

variable "dns_link_name" {
  description = "Name of the VNet link for the DNS zone"
  type        = string
}

variable "vnet_id" {
  description = "ID of the Virtual Network to link with the DNS zone"
  type        = string
}

variable "resource2_group_name" {
  description = "Name of the resource2 group"
  type        = string
  default     = "rgdevops"
}

variable "vnet2_name" {
  description = "Name of the Virtual Network two"
  type        = string
  default     = "vnet-centralindia-1"
}