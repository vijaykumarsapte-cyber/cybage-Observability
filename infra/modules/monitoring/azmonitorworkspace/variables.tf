variable "location" {
  type    = string
  default = "eastus"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "azmonitor_workspace_name" {
  description = "Name of the Azure Monitor Workspace"
  type        = string
}

variable "public_network_access" {
  description = "Enable or disable public network access"
  type        = bool
  default     = true
}

variable "common_tags" {
  type = map(string)
}

variable "aks_cluster_name" {
  description = "Name of the AKS cluster to integrate with Azure Monitor Workspace"
  type        = string
}

variable "action_group_name" {
  description = "Name of the Action Group for alerting"
  type        = string
  default     = "poc-alerts"
}