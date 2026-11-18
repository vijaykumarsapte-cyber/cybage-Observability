resource "azurerm_monitor_data_collection_endpoint" "dce" {
  name                = var.dce_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.common_tags
}

# A brand-new DCE is not immediately usable: creating the DCR right after it
# fails with "InvalidPayload: Data collection rule is invalid" (400). Wait for
# the DCE to propagate. Only delays the run in which the DCE is created.
resource "time_sleep" "wait_for_dce" {
  create_duration = "90s"
  triggers = {
    dce_id = azurerm_monitor_data_collection_endpoint.dce.id
  }
}

resource "azurerm_monitor_data_collection_rule" "dcr" {
  name                        = var.dcr_name
  resource_group_name         = var.resource_group_name
  location                    = var.location
  kind                        = "Linux"
  data_collection_endpoint_id = time_sleep.wait_for_dce.triggers["dce_id"]
  tags                        = var.common_tags

  dynamic "data_flow" {
    for_each = var.data_flows
    content {
      streams      = data_flow.value.streams
      destinations = data_flow.value.destinations
    }
  }

  dynamic "data_sources" {
    for_each = var.data_sources
    content {

      dynamic "prometheus_forwarder" {
        for_each = lookup(data_sources.value, "prometheus_forwarder", null) != null ? [1] : []
        content {
          name    = data_sources.value.prometheus_forwarder.name
          streams = data_sources.value.prometheus_forwarder.streams
        }
      }

      dynamic "extension" {
        for_each = lookup(data_sources.value, "extensions", null) != null ? data_sources.value.extensions : []
        content {
          name           = extension.value.name
          streams        = extension.value.streams
          extension_name = extension.value.extension_name
          extension_json = extension.value.extension_json
        }
      }
    }
  }

  dynamic "destinations" {
    for_each = var.destinations
    content {

      dynamic "monitor_account" {
        for_each = lookup(destinations.value, "monitor_account", null) != null ? [1] : []
        content {
          name               = destinations.value.monitor_account.name
          monitor_account_id = destinations.value.monitor_account.monitor_account_id
        }
      }

      dynamic "log_analytics" {
        for_each = lookup(destinations.value, "log_analytics", null) != null ? [1] : []
        content {
          name                  = destinations.value.log_analytics.name
          workspace_resource_id = destinations.value.log_analytics.workspace_resource_id
        }
      }
    }
  }

  depends_on = [
    azurerm_monitor_data_collection_endpoint.dce,
    time_sleep.wait_for_dce
  ]
}

resource "azurerm_monitor_data_collection_rule_association" "dcr_assoc" {
  name                    = coalesce(var.dcr_association_name, "${var.dcr_name}-assoc")
  target_resource_id      = var.target_resource_id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.dcr.id
}