# Private DNS Zone
resource "azurerm_private_dns_zone" "private_dns_zone" {
  name                = var.private_dns_zone
  resource_group_name = var.resource_group_name
}

data "azurerm_virtual_network" "vnet2" {
  name                = var.vnet2_name
  resource_group_name = var.resource2_group_name
}

# Link the DNS zone to the VNet
resource "azurerm_private_dns_zone_virtual_network_link" "dns_link" {
  name                  = var.dns_link_name
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.private_dns_zone.name
  virtual_network_id    = var.vnet_id
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnet2_link" {
  name                  = "${var.dns_link_name}-vnet2" 
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.private_dns_zone.name
  virtual_network_id    = data.azurerm_virtual_network.vnet2.id
  
  registration_enabled  = false
}