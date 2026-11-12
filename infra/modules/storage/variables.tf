variable "storage_account_name" {
  type        = string
  description = "Name of the Storage Account"
}

variable "location" {
  type        = string
  description = "Azure location"
  default     = "eastus"
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group NAme"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "storage_access_tier" {
  description = "The access tier used for the storage account blob data. 'Hot' or 'Cool'."
  type        = string
  default     = "Hot"
}

variable "storage_account_tier" {
  description = "The performance tier of the storage account. 'Standard' or 'Premium'."
  type        = string
  default     = "Standard"
}

variable "storage_account_kind" {
  description = "The kind of storage account. 'Storage', 'StorageV2', or 'BlobStorage'."
  type        = string
  default     = "StorageV2"
}

variable "storage_account_replication" {
  description = "The replication strategy for the storage account. 'LRS', 'GRS', etc."
  type        = string
  default     = "LRS"
}

variable "enable_https_traffic_only" {
  type    = bool
  default = true
}

variable "enable_public_network_access" {
  type    = bool
  default = false
}

variable "enable_shared_access_key" {
  type    = bool
  default = false
}

variable "ip_whitelist" {
  type    = list(string)
  default = []
}

variable "blob_containers" {
  type    = list(string)
  default = []
}

variable "file_shares" {
  description = "Map of file shares and their quotas (GB)"
  type = map(object({
    quota = number
  }))
  default = {}
}


variable "queues" {
  type    = list(string)
  default = []
}

# Private endpoints
variable "vnet_id" {
  type    = string
  default = null
}

variable "enable_private_endpoint_blob" {
  type    = bool
  default = false
}

variable "enable_private_endpoint_file" {
  type    = bool
  default = false
}

variable "enable_private_endpoint_queue" {
  type    = bool
  default = false
}

variable "private_endpoint_subnet_id" {
  type    = string
  default = null
}

variable "private_endpoint_name_blob" {
  description = "Name of the blob private endpoint."
  type        = string
}