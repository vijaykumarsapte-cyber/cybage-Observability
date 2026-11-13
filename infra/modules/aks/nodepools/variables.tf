variable "node_pool_name" {
  description = "Name of the AKS node pool"
  type        = string
}

variable "aks_cluster_id" {
  description = "Cluster Id of the AKS"
  type        = string
}

variable "node_vm_size" {
  description = "VM size for nodes (e.g., Standard_D2s_v3, Standard_NC6)"
  type        = string
}

variable "node_count" {
  description = "Initial node count for the node pool"
  type        = number
  default     = 1
}

variable "node_min_count" {
  description = "Minimum node count for autoscaling"
  type        = number
  default     = 1
}

variable "node_max_count" {
  description = "Maximum node count for autoscaling"
  type        = number
  default     = 3
}

variable "node_auto_scaling_enabled" {
  description = "Enable autoscaling for the node pool"
  type        = bool
  default     = false
}

variable "node_availability_zones" {
  description = "Availability zones for the node pool"
  type        = list(string)
  default     = ["1", "2"]
}

variable "node_taints" {
  description = "Node taints for the node pool (e.g., sku=gpu:NoSchedule)"
  type        = list(string)
  default     = []
}

variable "subnet_id" {
  type        = string
  description = "Id of the existing subnet in the VNet for AKS node pools."
}

variable "gpu_node" {
  description = "Indicates if the node pool is for GPU workloads"
  type        = bool
  default     = false  
}

variable "common_tags" {
  description = "Common tags including CostCenter required by org policy"
  type        = map(string)
  default     = {}
}
