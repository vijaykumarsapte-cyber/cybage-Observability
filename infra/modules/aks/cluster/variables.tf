variable "resource_group_name" {
  type        = string
  description = "Name of the existing resource group where AKS and other resources are deployed."
}

variable "location" {
  type        = string
  default     = "eastus"
  description = "Azure region for the AKS cluster."
}

variable "subnet_id" {
  type        = string
  description = "Id of the existing subnet in the VNet for AKS node pools."
}

variable "acr_name" {
  type        = string
  default     = "acrpoc"
  description = "Name of the existing Azure Container Registry (ACR) for pulling container images."
}

variable "cluster_name" {
  type        = string
  default     = "aks-poc"
  description = "Name of the AKS cluster."
}

variable "use_user_assigned_identity" {
  type        = bool
  default     = false
  description = "Flag to determine if a user assigned identity should be used for the AKS cluster."
}

variable "cluster_user_assigned_identity" {
  type        = string
  description = "User assigned_identity of the AKS cluster."
}

variable "dns_prefix" {
  type        = string
  default     = "aks-poc"
  description = "DNS prefix used by the AKS cluster for API server access."
}

variable "load_balancer_sku" {
  type        = string
  default     = "basic"
  description = "Load balancer sku for AKS load balancer service"
}

variable "kubernetes_version" {
  type        = string
  default     = null
  description = "Kubernetes version for the AKS cluster. Defaults to the latest supported version if null."
}

# System node pool configuration
variable "system_node_vm_size" {
  type        = string
  default     = "Standard_D4s_v3"
  description = "VM size for the AKS system node pool."
}

variable "system_node_count" {
  type        = number
  default     = 3
  description = "Number of nodes in the AKS system node pool."
}

variable "auto_scaling_enabled" {
  type        = bool
  default     = false
  description = "Define if auto scaling should be enabled (true / false)"
}

variable "min_node_count" {
  type        = number
  default     = 1
  description = "Minimum Number of nodes in the AKS system node pool."
}

variable "max_node_count" {
  type        = number
  default     = 3
  description = "Max Number of nodes in the AKS system node pool."
}

variable "enable_container_insights" {
  type        = bool
  description = "Enable container insights add-on"
  default     = false
}

variable "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics Workspace"
  type        = string
}

variable "enable_prometheus_monitoring" {
  type        = bool
  description = "Enable Prometheus monitoring add-on"
  default     = false
}

variable "monitor_allowed_annotations" {
  description = "Comma-separated k8s annotations to be included as labels in metrics"
  type        = string
  default     = "prometheus.io/scrape,prometheus.io/port,prometheus.io/path"
}

variable "monitor_allowed_labels" {
  description = "Comma-separated k8s labels to be included as labels in metrics"
  type        = string
  default     = "app,component,environment,team,release"
}

variable "enable_agic" {
  type        = bool
  description = "Enable App Gateway Ingress Controller add-on"
  default     = false
}

variable "application_gateway_id" {
  description = "Application Gateway resource ID"
  type        = string
  validation {
    condition     = var.enable_agic == false || (var.enable_agic && var.application_gateway_id != null && length(var.application_gateway_id) > 0)
    error_message = "If enable_agic is true, you must provide a valid application_gateway_id."
  }
}

variable "enable_aks_kv_secrets_provider" {
  type        = bool
  description = "Enable AKS Key Vault Secrets Provider add-on"
  default     = false
}

variable "enable_rbac" {
  description = "Enable RBAC for AKS"
  type        = bool
  default     = true
}

variable "enable_oidc" {
  description = "Enable OIDC for AKS"
  type        = bool
  default     = false
}

variable "enable_blob_csi_driver" {
  description = "Enable Blob CSI Driver for AKS"
  type        = bool
  default     = true
}

variable "enable_disk_csi_driver" {
  description = "Enable Disk CSI Driver for AKS"
  type        = bool
  default     = true  
}

variable "enable_file_csi_driver" {
  description = "Enable File CSI Driver for AKS"
  type        = bool
  default     = true  
}

# variable "aks_admin_group_object_id" {
#   description = "The object ID of the Azure AD group that will have admin access to the AKS cluster."
#   type        = string
# }

variable "iac_sp_object_id" {
  description = "The object ID of the Service Principal used by Infrastructure as Code (IaC) tools to manage AKS resources."
  type        = string
  default     = "poc-iac-terraform"
}

# variable "github_action_sp_object_id" {
#   description = "The object ID of the Service Principal used by Github Actions to manage AKS deployments."
#   type        = string
#   default     = "github-actions-poc"
# }

variable "enable_private_cluster" {
  description = "Enable private cluster for AKS"
  type        = bool
  default     = false
}

variable "private_dns_zone_id" {
  description = "The ID of the private DNS zone for the AKS private cluster."
  type        = string
}

variable "common_tags" {
  type    = map(string)
  default = {}
}