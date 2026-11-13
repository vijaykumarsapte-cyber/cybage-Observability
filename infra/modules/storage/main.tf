# Storage Account
resource "azurerm_storage_account" "storage" {
  name                          = var.storage_account_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  access_tier                   = var.storage_access_tier
  account_kind                  = var.storage_account_kind
  account_replication_type      = var.storage_account_replication
  account_tier                  = var.storage_account_tier
  https_traffic_only_enabled    = var.enable_https_traffic_only
  min_tls_version               = "TLS1_2"
  public_network_access_enabled = var.enable_public_network_access
  shared_access_key_enabled     = var.enable_shared_access_key
  allow_nested_items_to_be_public = false

  network_rules {
    default_action = "Deny"
    ip_rules       = var.ip_whitelist
    bypass         = ["AzureServices"]
  }

  blob_properties {
    container_delete_retention_policy {
      days = 7
    }
    delete_retention_policy {
      days                     = 7
      permanent_delete_enabled = false
    }
  }

  share_properties {
    retention_policy {
      days = 7
    }
  }

  lifecycle {
    ignore_changes = [
      network_rules[0].ip_rules,
    ]
  }
}


# Blob Containers
resource "azurerm_storage_container" "blob" {
  for_each              = toset(var.blob_containers)
  name                  = each.value
  storage_account_id    = azurerm_storage_account.storage.id
  container_access_type = "private"
}

# File Shares
resource "azurerm_storage_share" "files" {
  for_each           = var.file_shares
  name               = each.key
  quota              = each.value.quota
  storage_account_id = azurerm_storage_account.storage.id
}


# Queues
resource "azurerm_storage_queue" "queues" {
  for_each             = toset(var.queues)
  name                 = each.value
  storage_account_name = azurerm_storage_account.storage.name
}

# OPTIONAL PRIVATE ENDPOINTS
# Blob Private Endpoint
data "azurerm_private_dns_zone" "blob_pvt_dns_zone" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.resource_group_name
}

module "pe_blob" {
  source                 = "../network/privateEndpoint"
  count                  = var.enable_private_endpoint_blob ? 1 : 0
  private_endpoint_name  = var.private_endpoint_name_blob
  private_resource_id    = azurerm_storage_account.storage.id
  subresource_names      = ["blob"]
  location               = var.location
  resource_group_name    = var.resource_group_name
  subnet_id              = var.private_endpoint_subnet_id
  private_dns_zone       = "privatelink.blob.core.windows.net"
  private_dns_zone_group = "${var.storage_account_name}-blob-dns"
  private_dns_zone_ids   = [data.azurerm_private_dns_zone.blob_pvt_dns_zone.id]
}

# File Private Endpoint
data "azurerm_private_dns_zone" "file_pvt_dns_zone" {
  count               = var.enable_private_endpoint_file ? 1 : 0
  name                = "privatelink.file.core.windows.net"
  resource_group_name = var.resource_group_name
}

module "pe_file" {
  source                 = "../network/privateEndpoint"
  count                  = var.enable_private_endpoint_file ? 1 : 0
  private_endpoint_name  = "${var.storage_account_name}-file-pe"
  private_resource_id    = azurerm_storage_account.storage.id
  subresource_names      = ["file"]
  location               = var.location
  resource_group_name    = var.resource_group_name
  subnet_id              = var.private_endpoint_subnet_id
  private_dns_zone       = "privatelink.file.core.windows.net"
  private_dns_zone_group = "${var.storage_account_name}-file-dns"
  private_dns_zone_ids   = [data.azurerm_private_dns_zone.file_pvt_dns_zone[0].id]
}

# Queue Private Endpoint
module "pe_queue" {
  source                 = "../network/privateEndpoint"
  count                  = var.enable_private_endpoint_queue ? 1 : 0
  private_endpoint_name  = "${var.storage_account_name}-queue-pe"
  private_resource_id    = azurerm_storage_account.storage.id
  subresource_names      = ["queue"]
  location               = var.location
  resource_group_name    = var.resource_group_name
  subnet_id              = var.private_endpoint_subnet_id
  private_dns_zone       = "privatelink.queue.core.windows.net"
  private_dns_zone_group = "${var.storage_account_name}-queue-dns"
}

