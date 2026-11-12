resource "azurerm_dashboard_grafana" "grafana" {
  name                  = var.grafana_name
  location              = var.location
  resource_group_name   = var.resource_group_name
  sku                   = var.grafana_sku
  grafana_major_version = var.grafana_version
  tags                  = var.common_tags

  public_network_access_enabled = var.public_network_access_enabled

  identity {
    type = "SystemAssigned"
  }

  azure_monitor_workspace_integrations {
    resource_id = var.azmonitor_workspace_id
  }
}

resource "azurerm_dashboard_grafana_managed_private_endpoint" "managed_pe" {
  count                        = var.create_managed_pe ? 1 : 0
  grafana_id                   = azurerm_dashboard_grafana.grafana.id
  name                         = "${var.grafana_name}-mpe"
  location                     = var.location
  private_link_resource_id     = var.azmonitor_workspace_id
  group_ids                    = ["prometheusMetrics"]
  private_link_resource_region = azurerm_dashboard_grafana.grafana.location
}

# Monitoring Data Reader Role Assignment for Grafana Managed Identity
module "role_assignment_grafana_monitoring_data_reader" {
  source     = "../../authorization/roleAssignments"
  scope      = var.azmonitor_workspace_id
  role_name  = "Monitoring Data Reader"
  object_id  = azurerm_dashboard_grafana.grafana.identity[0].principal_id
  depends_on = [azurerm_dashboard_grafana.grafana]
}

# Log Analytics Reader Role Assignment for Grafana Managed Identity
module "role_assignment_grafana_law_reader" {
  source     = "../../authorization/roleAssignments"
  scope      = var.log_analytics_workspace_id
  role_name  = "Log Analytics Reader"
  object_id  = azurerm_dashboard_grafana.grafana.identity[0].principal_id
  depends_on = [azurerm_dashboard_grafana.grafana]
}

module "role_assignments_grafana_admins" {
  source     = "../../authorization/roleAssignments"
  for_each   = toset(var.grafana_admins)
  scope      = azurerm_dashboard_grafana.grafana.id
  role_name  = "Grafana Admin"
  object_id  = each.value
  depends_on = [azurerm_dashboard_grafana.grafana]
}

module "role_assignments_grafana_readers" {
  source     = "../../authorization/roleAssignments"
  for_each   = toset(var.grafana_readers)
  scope      = azurerm_dashboard_grafana.grafana.id
  role_name  = "Grafana Viewer"
  object_id  = each.value
  depends_on = [azurerm_dashboard_grafana.grafana]
}

module "role_assignments_grafana_editors" {
  source     = "../../authorization/roleAssignments"
  for_each   = toset(var.grafana_editors)
  scope      = azurerm_dashboard_grafana.grafana.id
  role_name  = "Grafana Editor"
  object_id  = each.value
  depends_on = [azurerm_dashboard_grafana.grafana]
}