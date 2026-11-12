# Additional AKS Node Pool (e.g., GPU, Spot, or other workloads)
resource "azurerm_kubernetes_cluster_node_pool" "user_node_pool" {
  name                        = var.node_pool_name
  kubernetes_cluster_id       = var.aks_cluster_id
  auto_scaling_enabled        = var.node_auto_scaling_enabled
  node_count                  = var.node_auto_scaling_enabled ? null : var.node_count
  min_count                   = var.node_auto_scaling_enabled ? var.node_min_count : null
  max_count                   = var.node_auto_scaling_enabled ? var.node_max_count : null
  os_type                     = "Linux"
  mode                        = "User"
  vm_size                     = var.node_vm_size
  vnet_subnet_id              = var.subnet_id
  zones                       = var.node_availability_zones
  node_taints                 = var.node_taints
  temporary_name_for_rotation = "tempusernode"
  # gpu_driver                  = var.gpu_node ? "Install" : null
  tags = var.common_tags

  # Force recreation if taints change
  lifecycle {
    create_before_destroy = true
  }

  upgrade_settings {
    drain_timeout_in_minutes      = 30
    max_surge                     = "10%"
    node_soak_duration_in_minutes = 30
  }

  # Conditionally Ensure NVIDIA drivers are installed
  dynamic "linux_os_config" {
    for_each = var.gpu_node ? [1] : []
    content {
      sysctl_config {
        net_core_somaxconn = 16384
      }
    }
  }
}

