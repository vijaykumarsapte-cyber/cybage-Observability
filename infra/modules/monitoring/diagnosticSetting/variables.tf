variable "diagnostic_settings_name" {
  description = "Name of the Application Insights resource."
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "ID of the Log Analytics Workspace."
  type        = string
}

variable "aks_cluster_id" {
  description = "Cluster Id of the AKS"
  type        = string
}