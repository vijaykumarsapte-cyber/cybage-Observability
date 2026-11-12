# Private DNS Zone
resource "azurerm_private_dns_zone" "private_dns_zone" {
  name                = var.private_dns_zone
  resource_group_name = var.resource_group_name
}

# Link the DNS zone to the workload VNet
resource "azurerm_private_dns_zone_virtual_network_link" "dns_link" {
  name                  = var.dns_link_name
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.private_dns_zone.name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false
}

# Optional links to additional VNets (e.g. a peered jump-box VNet). The caller
# passes the VNet IDs; this module does not look up VNets itself.
# Link name: "<dns_link_name>-<map key>".
resource "azurerm_private_dns_zone_virtual_network_link" "additional" {
  for_each = var.additional_vnet_links

  name                  = "${var.dns_link_name}-${each.key}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.private_dns_zone.name
  virtual_network_id    = each.value
  registration_enabled  = false
}
