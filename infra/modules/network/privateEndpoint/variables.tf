variable "location" {
  description = "Azure region where the private endpoint will be deployed"
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "private_endpoint_name" {
  description = "Name of the private endpoint"
  type        = string
}

variable "enable_private_endpoint" {
  type    = bool
  default = false
}

variable "subnet_id" {
  description = "Subnet for private endpoint"
  type        = string
  default     = null
}

variable "private_dns_zone" {
  description = "Name of the private DNS zone"
  type        = string
}

variable "private_dns_zone_group" {
  description = "Private DNS Zone Group Name for Redis"
  type        = string
}

variable "private_dns_zone_ids" {
  description = "Private DNS Zone IDs for Redis"
  type        = list(string)
  default     = []
}

variable "private_resource_id" {
  description = "Resource ID of the target resource for the private endpoint (e.g., the Redis resource ID)."
  type        = string
}

variable "subresource_names" {
  description = "Subresource names for the private endpoint"
  type        = list(string)
  default     = ["redisEnterprise"]
}