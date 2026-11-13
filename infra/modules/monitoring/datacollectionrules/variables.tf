variable "location" {
  type    = string
  default = "eastus"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "aks_cluster_name" {
  type        = string
  description = "Name of the AKS cluster."
}

variable "azmonitor_workspace_id" {
  type        = string
  description = "The ID of the Azure Monitor Workspace to send data to."  
}