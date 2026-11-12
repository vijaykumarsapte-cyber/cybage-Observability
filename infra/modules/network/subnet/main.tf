resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = var.subnet_address_space
  service_endpoints    = var.service_endpoints

  dynamic "delegation" {
    for_each = var.delegations
    content {
      name = "delegation"
      service_delegation {
        name    = delegation.value.service_delegation.name
        actions = lookup(delegation.value.service_delegation, "actions", null)
      }
    }
  }
}
