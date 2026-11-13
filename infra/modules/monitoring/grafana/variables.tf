variable "location" {
  type    = string
  default = "eastus"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "grafana_name" {
  description = "Name of the Grafana instance"
  type        = string
}

variable "grafana_sku" {
  description = "Grafana SKU"
  type        = string
  default     = "Standard"
}

variable "grafana_version" {
  description = "Grafana major version"
  type        = string
  default     = "11"
}

variable "azmonitor_workspace_id" {
  description = "Azure Monitor Workspace ID"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID"
  type        = string  
}

variable "grafana_admins" {
  type        = list(string)
  description = "List of Service Principal Object IDs to be granted grafana admin role"
}

variable "grafana_readers" {
  type        = list(string)
  description = "List of Service Principal Object IDs to be granted grafana reader role"
}

variable "grafana_editors" {
  type        = list(string)
  description = "List of Service Principal Object IDs to be granted grafana editor role"
}

variable "create_managed_pe" {
  description = "Whether to create a managed private endpoint for Grafana to connect to Azure Monitor Workspace"
  type        = bool
  default     = false
}

variable "common_tags" {
  type = map(string)
}

variable "public_network_access_enabled" {
  description = "Whether to allow public network access to the Grafana instance"
  type        = bool
  default     = true
}