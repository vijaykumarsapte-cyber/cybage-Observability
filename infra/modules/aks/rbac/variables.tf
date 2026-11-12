variable "resource_group_name" {
  type        = string
  description = "Name of the existing resource group where AKS and other resources are deployed."
}

variable "location" {
  type        = string
  default     = "eastus"
  description = "Azure region for the AKS cluster."
}

variable "aks_cluster_name" {
  description = "Cluster Id of the AKS"
  type        = string
}

variable "namespaces" {
  description = "List of namespaces to create"
  type        = list(string)
  default     = ["dev", "prod"]
}

variable "aks_admin_group_object_id" {
  type        = string
  description = "Entra ID group for cluster admin"
}

variable "dev_group_object_id" {
  type        = string
  description = "Entra ID group for dev namespace"
}

variable "prod_group_object_id" {
  type        = string
  description = "Entra ID group for prod namespace"
}


# Map namespace -> list of rule objects to apply to the "namespace-admin" role
# Each rule object: { api_groups = list(string), resources = list(string), verbs = list(string) }
variable "admin_role_rules" {
  type = map(list(object({
    api_groups = list(string)
    resources  = list(string)
    verbs      = list(string)
  })))
  default = {
    dev = [
      {
        api_groups = ["", "apps", "extensions"]
        resources  = ["*"]
        verbs      = ["*"]
      }
    ]
    prod = [
      {
        api_groups = ["", "apps", "extensions"]
        resources  = ["*"]
        verbs      = ["*"]
      }
    ]
  }
}

# Map namespace -> list of rule objects for the "app" role (non-admin)
variable "app_role_rules" {
  type = map(list(object({
    api_groups = list(string)
    resources  = list(string)
    verbs      = list(string)
  })))
  default = {
    dev = [
      {
        api_groups = [""]
        resources  = ["pods", "services", "deployments"]
        verbs      = ["get", "list", "watch", "create", "update", "delete"]
      }
    ]
    prod = [
      {
        api_groups = [""]
        resources  = ["pods", "services", "deployments"]
        verbs      = ["get", "list", "watch"]
      }
    ]
  }
}

locals {
  namespace_admin_groups = {
    dev     = var.aks_admin_group_object_id
    staging = var.aks_admin_group_object_id
    prod    = var.aks_admin_group_object_id
  }

  namespace_app_group = {
    dev     = var.dev_group_object_id
    staging = var.prod_group_object_id
    prod    = var.prod_group_object_id
  }
}

variable "workload_identity_client_id" {
  description = "The client ID for Azure Workload Identity"
  type        = string
}

variable "cluster_admin_role_sp_object_ids" {
  type        = list(string)
  description = "List of Service Principal Object IDs to be granted cluster-admin role."
}