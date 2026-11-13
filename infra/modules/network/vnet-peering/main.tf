
data "azurerm_virtual_network" "vnet1" {
  name                = var.vnet1_name
  resource_group_name = var.resource1_group_name
}

data "azurerm_virtual_network" "vnet2" {
  name                = var.vnet2_name
  resource_group_name = var.resource2_group_name
}

# VNet 1 -> VNet 2
resource "azurerm_virtual_network_peering" "vnet1_to_vnet2" {
  name                      = "v1tov2"
  resource_group_name       = data.azurerm_virtual_network.vnet1.resource_group_name
  virtual_network_name      = data.azurerm_virtual_network.vnet1.name
  remote_virtual_network_id = data.azurerm_virtual_network.vnet2.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

# VNet 2 -> VNet 1
resource "azurerm_virtual_network_peering" "vnet2_to_vnet1" {
  name                      = "v2tov1"
  resource_group_name       = data.azurerm_virtual_network.vnet2.resource_group_name
  virtual_network_name      = data.azurerm_virtual_network.vnet2.name
  remote_virtual_network_id = data.azurerm_virtual_network.vnet1.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit         = false
  use_remote_gateways           = false
}