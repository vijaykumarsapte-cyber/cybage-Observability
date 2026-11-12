# Define existing AKS cluster resource
data "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_cluster_name
  resource_group_name = var.resource_group_name
}

# Data Collection Endpoint (DCE)
resource "azurerm_monitor_data_collection_endpoint" "dce" {
  name                = "${var.aks_cluster_name}-${var.location}-dce"
  location            = var.location
  resource_group_name = var.resource_group_name
}

# Data Collection Rule (DCR)
resource "azurerm_monitor_data_collection_rule" "prometheus_dcr" {
  name                        = "${var.aks_cluster_name}-${var.location}-dcr"
  resource_group_name         = var.resource_group_name
  location                    = var.location
  kind                        = "Linux"
  data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.dce.id

  data_flow {
    streams = [
      "Microsoft-PrometheusMetrics"
    ]
    destinations = [
      "azureMonitorWorkspace1"
    ]
  }
  data_sources {
    prometheus_forwarder {
      name = "prometheusDataSource"
      streams = [
        "Microsoft-PrometheusMetrics"
      ]
    }
  }

  destinations {
    monitor_account {
      monitor_account_id = var.azmonitor_workspace_id
      name               = "azureMonitorWorkspace1"
    }
  }
  depends_on = [azurerm_monitor_data_collection_endpoint.dce]
}


# Associate DCR with AKS cluster (so DCR applies to AKS)
resource "azurerm_monitor_data_collection_rule_association" "dcr_assoc" {
  name                    = "${var.aks_cluster_name}-dcr-association"
  target_resource_id      = data.azurerm_kubernetes_cluster.aks.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.prometheus_dcr.id

  depends_on = [azurerm_monitor_data_collection_rule.prometheus_dcr]
}
