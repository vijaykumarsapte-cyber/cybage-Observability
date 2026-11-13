resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  tags = var.common_tags

  default_node_pool {
    name                        = "system"
    vm_size                     = var.system_node_vm_size
    vnet_subnet_id              = var.subnet_id
    auto_scaling_enabled        = var.auto_scaling_enabled
    node_count                  = var.auto_scaling_enabled ? null : var.system_node_count
    min_count                   = var.auto_scaling_enabled ? var.min_node_count : null
    max_count                   = var.auto_scaling_enabled ? var.max_node_count : null
    zones = ["1", "2"]
    temporary_name_for_rotation = "tempsys"
    tags = var.common_tags
    upgrade_settings {
      drain_timeout_in_minutes      = 30
      max_surge                     = "10%"
      node_soak_duration_in_minutes = 30
    }
  }

  identity {
    type = var.use_user_assigned_identity ? "UserAssigned" : "SystemAssigned"

    # Attach identity IDs only if UserAssigned
    identity_ids = var.use_user_assigned_identity ? [var.cluster_user_assigned_identity] : null
  }

  # Azure CNI overlay network configuration
  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    pod_cidrs           = ["100.112.0.0/19"]
    service_cidr        = "10.0.0.0/16"
    dns_service_ip      = "10.0.0.10"
    load_balancer_sku   = var.load_balancer_sku
    outbound_type = "loadBalancer"
  }

  # Conditionally add Container insights 
  dynamic "oms_agent" {
    for_each = var.enable_container_insights ? [1] : []
    content {
      log_analytics_workspace_id      = var.log_analytics_workspace_id
      msi_auth_for_monitoring_enabled = true
    }
  }

  # Conditionally add Prometheus monitoring
  dynamic "monitor_metrics" {
    for_each = var.enable_prometheus_monitoring ? [1] : []
    content {
      annotations_allowed = var.monitor_allowed_annotations
      labels_allowed      = var.monitor_allowed_labels
    }
  }

  # Conditionally add AGIC
  dynamic "ingress_application_gateway" {
    for_each = var.enable_agic ? [1] : []
    content {
      gateway_id = var.application_gateway_id
    }
  }

  # Conditionally add KV Secrets Provider
  dynamic "key_vault_secrets_provider" {
    for_each = var.enable_aks_kv_secrets_provider ? [1] : []
    content {
      secret_rotation_enabled  = true
      secret_rotation_interval = "2m"
    }
  }

  private_cluster_enabled = var.enable_private_cluster
  private_dns_zone_id     = var.private_dns_zone_id
  # api_server_access_profile {
  #   subnet_id                           = var.aks_api_subnet_id
  #   virtual_network_integration_enabled = true

  # }

  oidc_issuer_enabled               = var.enable_oidc
  workload_identity_enabled         = var.enable_oidc
  role_based_access_control_enabled = var.enable_rbac

  # Enable CSI Storage Drivers
  storage_profile {
    blob_driver_enabled = var.enable_blob_csi_driver
    disk_driver_enabled = var.enable_disk_csi_driver
    file_driver_enabled = var.enable_file_csi_driver
  }


  # azure_active_directory_role_based_access_control {
  #   admin_group_object_ids = [var.aks_admin_group_object_id]
  #   azure_rbac_enabled     = false # this should be false as we are using Microsoft Entra ID authentication with Kubernetes RBAC
  # }
}



