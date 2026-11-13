# Get the existing AKS private DNS zone
data "azurerm_private_dns_zone" "aks" {
  name                = var.aks_private_dns_zone_name
  resource_group_name = var.aks_private_dns_zone_rg
}

# Get the existing VNet containing the VM
data "azurerm_virtual_network" "vm_vnet" {
  name                = var.vm_vnet_name
  resource_group_name = var.vm_vnet_rg
}

# Link AKS private DNS zone with VM VNet
resource "azurerm_private_dns_zone_virtual_network_link" "aks_vm_vnet" {
  name                  = var.vlinkname 
  resource_group_name   = data.azurerm_private_dns_zone.aks.resource_group_name
  private_dns_zone_name = data.azurerm_private_dns_zone.aks.name
  virtual_network_id    = data.azurerm_virtual_network.vm_vnet.id
  registration_enabled  = false
}