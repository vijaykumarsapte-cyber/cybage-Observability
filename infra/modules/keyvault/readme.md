# Azure Key Vault Module

This Terraform module provisions an Azure Key Vault (azurerm_key_vault) with common configuration options: SKU, soft-delete/purge protection, access policies, and optional network access / firewall settings.

## Usage

```hcl
module "key_vault" {
  source              = "./modules/keyvault"

  # Required
  resource_group_name = "rg-secrets"        # required
  location            = "eastus"           # required (Azure requires a location)
  key_vault_name      = "kv-poc-prod"       # required (must be globally unique within vault name constraints)
  tenant_id           = "00000000-0000-0000-0000-000000000000" # required (Azure AD tenant ID for the vault)

  # Optional (examples)
  sku_name            = "standard"          # default: "standard"
  soft_delete_enabled = true               # default: true (soft delete retention controlled by provider)
  purge_protection    = false              # default: false
  access_policies     = []                 # list(map) of access policy blocks (object_id, tenant_id, permissions)
  network_acls = {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    ip_rules                   = []
    virtual_network_subnet_ids = []
  }
}
```

## Variables

| Name                 | Type         | Description                                                                                     | Required | Default |
|----------------------|--------------|-------------------------------------------------------------------------------------------------|----------|---------|
| resource_group_name  | string       | Name of the resource group where Key Vault will be created. Azure requires a resource group.   | Yes      | n/a     |
| location             | string       | Azure region where the Key Vault will be created. Azure requires a location.                   | Yes      | "eastus" |
| key_vault_name       | string       | Name of the Key Vault (must meet Azure naming rules).                                          | Yes      | n/a     |
| tenant_id            | string       | Azure AD tenant ID that will own the Key Vault. Required by the Key Vault resource.            | Yes      | n/a     |
| sku_name             | string       | SKU name for the vault ("standard" or "premium").                                              | No       | "standard" |
| soft_delete_enabled  | bool         | Enable soft-delete for the vault (recommended).                                                 | No       | true    |
| purge_protection     | bool         | Enable purge protection to prevent permanent deletion.                                          | No       | false   |
| access_policies      | list(object) | List of access policy objects (each should include object_id, tenant_id, and permissions maps).  | No       | []      |
| network_acls         | map/object   | Network ACLs / firewall configuration (default_action, bypass, ip_rules, virtual_network_subnet_ids). | No | {} |
| enabled_for_deployment | bool       | Allow trusted Azure services to access Key Vault for deployment tasks.                          | No       | false   |
| enabled_for_disk_encryption | bool  | Allow disk encryption to access Key Vault.                                                      | No       | false   |
| enabled_for_template_deployment | bool | Allow template deployment to access Key Vault.                                                 | No       | false   |

Notes on required flags:
- resource_group_name, location, key_vault_name, and tenant_id are required by the Azure Key Vault resource (azurerm_key_vault) and must be provided even if the module supplies defaults for other items.
- access_policies entries must use Azure AD object IDs (GUIDs) for principals (service principals, managed identities, users, groups).

## Outputs

| Name               | Description |
|--------------------|-------------|
| key_vault_id       | Resource ID of the created Key Vault (azurerm_key_vault.<name>.id) |
| key_vault_name     | Name of the created Key Vault (azurerm_key_vault.<name>.name) |
| key_vault_uri      | Vault URI (https endpoint) for the Key Vault (azurerm_key_vault.<name>.vault_uri) |
| key_vault_resource | Full resource object / map (if the module exposes it) |

## Notes & Recommendations

- Ensure the identity running Terraform has proper permissions to create Key Vaults and update access policies in the target subscription/resource group.
- Prefer assigning least-privilege access via access_policies or by using RBAC-enabled Key Vault configuration where supported.
- Consider enabling purge_protection in production to avoid accidental permanent deletion.
- When using network restrictions, ensure any managed/private endpoints and trusted services are allowed to access the vault.
- Avoid placing secrets directly in Terraform code; use Key Vault to store secrets and reference them via data sources or external secret management.

## References

- azurerm_key_vault — https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault
- Azure Key Vault concepts — https://learn.microsoft.com/azure/key-vault/