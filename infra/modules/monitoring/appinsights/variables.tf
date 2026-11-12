variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
}

variable "location" {
  description = "Location for the resources."
  type        = string
  default     = "eastus"
}

variable "app_insights_name" {
  description = "Name of the Application Insights resource."
  type        = string
}

variable "application_type" {
  description = "Type of Application Insights (e.g., web, other)."
  type        = string
  default     = "web"
}

variable "log_analytics_workspace_id" {
  description = "ID of the Log Analytics Workspace."
  type        = string
}

variable "daily_data_cap" {
  description = "Daily data cap of Application Insights in GB."
  type        = number
  default     = 10
}

variable "tags" {
  description = "Tags to apply to the resource."
  type        = map(string)
  default     = {}
}
