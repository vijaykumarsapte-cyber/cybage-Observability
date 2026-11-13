variable "dce_name" {
  description = "Name of the Data Collection Endpoint"
  type        = string
}

variable "dcr_name" {
  description = "Name of the Data Collection Rule"
  type        = string
}

variable "dcr_association_name" {
  description = "Optional name for the DCR association. Defaults to <dcr_name>-assoc. Use ContainerInsightsExtension for Container Insights."
  type        = string
  default     = null
}

variable "location" {
  description = "Azure region for DCE & DCR"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group for DCE & DCR"
  type        = string
}

variable "target_resource_id" {
  description = "AKS cluster resource ID for DCR association"
  type        = string
}

variable "data_flows" {
  description = "List of data flows (streams to destinations)"
  type = list(object({
    streams      = list(string)
    destinations = list(string)
  }))
}

variable "data_sources" {
  description = "List of data sources including Prometheus and ContainerInsights extensions"
  type = list(object({

    prometheus_forwarder = optional(object({
      name    = string
      streams = list(string)
    }))

    extensions = optional(list(object({
      name           = string
      streams        = list(string)
      extension_name = string
      extension_json = optional(string)
    })))
  }))
}

variable "destinations" {
  description = "Destinations such as Monitor Account or Log Analytics"
  type = list(object({

    monitor_account = optional(object({
      name               = string
      monitor_account_id = string
    }))

    log_analytics = optional(object({
      name                  = string
      workspace_resource_id = string
    }))
  }))
}

variable "common_tags" {
  type = map(string)
}