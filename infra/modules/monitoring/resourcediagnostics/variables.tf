variable "diagnostic_settings_name" {
  description = "Name of the diagnostic setting"
  type        = string
}

variable "target_resource_id" {
  description = "Resource ID to collect diagnostics from"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID"
  type        = string
}

variable "log_categories" {
  description = "Log categories to enable"
  type        = list(string)
  default     = []
}

variable "metric_categories" {
  description = "Metric categories to enable"
  type        = list(string)
  default     = ["AllMetrics"]
}