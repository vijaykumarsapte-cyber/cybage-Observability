data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "keyvault" {
  name                          = var.keyvault_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = var.keyvault_sku_name
  soft_delete_retention_days    = var.soft_delete_retention_days
  purge_protection_enabled      = var.enable_purge_protection
  enable_rbac_authorization     = var.enable_rbac_authorization
  public_network_access_enabled = var.public_network
}

data "azurerm_private_dns_zone" "kv_pvt_dns_zone" {
  count               = var.public_network ? 0 : 1
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.resource_group_name
}

module "keyvault_pe" {
  source = "../network/privateEndpoint"
  count  = var.public_network ? 0 : 1

  resource_group_name    = var.resource_group_name
  location                = var.location
  private_resource_id    = azurerm_key_vault.keyvault.id
  private_endpoint_name  = var.private_endpoint_name
  private_dns_zone       = "privatelink.vaultcore.azure.net"
  subresource_names      = ["vault"]
  subnet_id              = var.private_endpoint_subnet_id
  private_dns_zone_group = "${var.keyvault_name}-dns"
  private_dns_zone_ids   = [data.azurerm_private_dns_zone.kv_pvt_dns_zone[0].id]
}