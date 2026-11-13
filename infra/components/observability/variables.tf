variable "subscription_id" {
  description = "Azure subscription ID."
  type        = string
}

variable "tenant_id" {
  description = "Microsoft Entra tenant ID."
  type        = string
}

variable "location" {
  description = "Azure region for all resources."
  type        = string
}

variable "rg_name" {
  description = "Name of the resource group."
  type        = string
}

variable "vnet_name" {
  description = "Name of the virtual network."
  type        = string
}

variable "enable_agent_vnet_connectivity" {
  description = "Peer the workload VNet with an existing build-agent / jump-box VNet and link the private DNS zones (ACR, KV, blob, AKS) to it. The VNet must already exist."
  type        = bool
  default     = false
}

variable "agent_vnet_rg_name" {
  description = "Resource group of the existing build-agent VNet (used only when enable_agent_vnet_connectivity = true)."
  type        = string
  default     = ""
}

variable "agent_vnet_name" {
  description = "Name of the existing build-agent VNet (used only when enable_agent_vnet_connectivity = true)."
  type        = string
  default     = ""
}

variable "vlinkname" {
  description = "Name of the AKS private DNS zone link to the build-agent VNet."
  type        = string
  default     = "aks-private-dns-agent-vnet-link"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network."
  type        = string
}

variable "app_subnet_name" {
  description = "Name of the app subnet."
  type        = string
}

variable "app_subnet_prefix" {
  description = "Address prefix for the app subnet."
  type        = string
}

variable "appgw_subnet_name" {
  description = "Name of the Application Gateway subnet."
  type        = string
}

variable "appgw_subnet_prefix" {
  description = "Address prefix for the Application Gateway subnet."
  type        = string
}

variable "appgw_name" {
  description = "Name of the Application Gateway."
  type        = string
}

variable "pe_subnet_name" {
  description = "Name of the private endpoint subnet."
  type        = string
}

variable "pe_subnet_prefix" {
  description = "Address prefix for the private endpoint subnet."
  type        = string
}

variable "nsg_app_name" {
  description = "Name of the NSG attached to the app subnet."
  type        = string
}

variable "nsg_appgw_name" {
  description = "Name of the NSG attached to the Application Gateway subnet."
  type        = string
}

variable "nsg_pe_name" {
  description = "Name of the NSG attached to the private endpoint subnet."
  type        = string
}

variable "acr_name" {
  description = "Name of the Azure Container Registry."
  type        = string
}

variable "public_network_access_enabled" {
  description = "Whether ACR allows public network access."
  type        = bool
  default     = false
}

variable "kv_name" {
  description = "Name of the Key Vault."
  type        = string
}

variable "kv_pe_name" {
  description = "Name of the Key Vault private endpoint."
  type        = string
}

variable "storage_account_name" {
  description = "Name of the storage account."
  type        = string
}

variable "aks_name" {
  description = "Name of the AKS cluster."
  type        = string
}

variable "aks_dns_prefix" {
  description = "DNS prefix for the AKS cluster."
  type        = string
}

variable "system_node_vm_size" {
  description = "VM size for the AKS system node pool."
  type        = string
}

variable "app_node_vm_size" {
  description = "VM size for the AKS app node pool."
  type        = string
}

variable "observability_node_vm_size" {
  description = "VM size for the AKS observability node pool."
  type        = string
}

variable "workload_identity_name" {
  description = "Name of the user-assigned managed identity used for workload identity federation."
  type        = string
}

variable "tags" {
  description = "Common tags applied to all resources."
  type        = map(string)
}

variable "acr_pe_name" {
  description = "Name of the ACR private endpoint."
  type        = string
}

variable "blob_pe_name" {
  description = "Name of the storage blob private endpoint."
  type        = string
}

variable "log_analytics_workspace_name" {
  type        = string
  description = "Log Analytics workspace name"
}