# ----------------------------------------------------------------------
# Public IP for Bastion
# ----------------------------------------------------------------------
resource "azurerm_public_ip" "bastion_pip" {
  name                = "${var.vnet_name}-bastion-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# ----------------------------------------------------------------------
# Bastion Host
# ----------------------------------------------------------------------
resource "azurerm_bastion_host" "bastion" {
  name                = "${var.vnet_name}-bastion"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.bastion_host_sku
  tunneling_enabled   = var.enable_tunneling

  ip_configuration {
    name                 = "configuration"
    subnet_id            = var.bastion_subnet_id
    public_ip_address_id = azurerm_public_ip.bastion_pip.id
  }

  depends_on = [azurerm_public_ip.bastion_pip]
}


