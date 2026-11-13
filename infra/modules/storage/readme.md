# Azure Storage Account Module

This Terraform module provisions an Azure Storage Account (azurerm_storage_account) with common options: SKU, kind, hierarchical namespace (ADLS Gen2), network rules, and optional container creation.

## Usage

```hcl
module "storage" {
  source               = "./modules/storage"

  # Required
  resource_group_name  = "rg-storage"           # required
  location             = "eastus"              # required (Azure requires a location)
  storage_account_name = "pocstorageacct01"     # required (must be globally unique within Azure storage naming constraints)

  # Optional
  sku_name             = "Standard_LRS"
  kind                 = "StorageV2"
  enable_https_only    = true
  min_tls_version      = "TLS1_2"
  allow_blob_public_access = false
  is_hns_enabled       = false                 # enable for ADLS Gen2
  access_tier          = "Hot"                 # for blob storage (Hot / Cool)
  containers = [
    { name = "app-logs"   , public_access = "private" },
    { name = "static-web" , public_access = "blob"    },
  ]

  network_rules = {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    ip_rules                   = []
    virtual_network_subnet_ids = []
  }
}

# Example of consuming outputs:
output "storage_account_id" {
  value = module.storage.storage_account_id
}
```

## Variables

| Name                  | Type         | Description                                                                                         | Required | Default       |
|-----------------------|--------------|-----------------------------------------------------------------------------------------------------|----------|---------------|
| resource_group_name   | string       | Name of the resource group where the storage account will be created. Azure requires a resource group. | Yes      | n/a           |
| location              | string       | Azure region where the storage account will be created. Azure requires a location.                 | Yes      | "eastus"     |
| storage_account_name  | string       | Name of the storage account (must meet Azure naming rules and be globally unique).                 | Yes      | n/a           |
| sku_name              | string       | SKU for the storage account (e.g., "Standard_LRS", "Standard_GRS", "Premium_LRS").                | No       | "Standard_LRS"|
| kind                  | string       | Storage account kind. Typical value: "StorageV2".                                                  | No       | "StorageV2"   |
| enable_https_only     | bool         | Restrict access to HTTPS only.                                                                      | No       | true          |
| min_tls_version       | string       | Minimum TLS version (e.g., "TLS1_2").                                                               | No       | "TLS1_2"      |
| allow_blob_public_access | bool      | Whether to allow public access to blob containers.                                                  | No       | false         |
| is_hns_enabled        | bool         | Enable hierarchical namespace (ADLS Gen2).                                                          | No       | false         |
| access_tier           | string       | Default access tier for blob data ("Hot" or "Cool").                                                | No       | "Hot"         |
| network_rules         | map/object   | Network restrictions: default_action, bypass, ip_rules (list), virtual_network_subnet_ids (list).   | No       | {}            |
| containers            | list(object) | Optional list of containers to create. Each object: { name = string, public_access = "private"|"blob"|"container" } | No | [] |

Notes:
- Although the module may provide defaults for some fields, Azure requires an explicit resource group and location for resource creation; these are marked required.
- storage_account_name must follow Azure storage naming rules (lowercase letters and numbers, 3-24 characters).

## Outputs

| Name                       | Description |
|----------------------------|-------------|
| storage_account_id         | Resource ID of the created Storage Account (azurerm_storage_account.*.id) |
| storage_account_name       | Name of the created Storage Account |
| primary_blob_endpoint      | Primary blob service endpoint URL |
| primary_web_endpoint       | Primary static website endpoint (if static website enabled) |
| primary_location           | Primary location/region of the storage account |
| primary_connection_string  | Primary connection string for the storage account (if exposed by module) |

Note: Connection strings and other sensitive outputs should be treated as sensitive in Terraform and in CI/CD pipelines.

## Notes & Recommendations

- Ensure the identity running Terraform has Microsoft.Storage/* permissions at the target scope to create storage resources.
- For production workloads, prefer "StorageV2" with "Standard_LRS" or appropriate geo-redundant SKU and enable TLS1_2.
- If enabling hierarchical namespace (is_hns_enabled = true), the account becomes ADLS Gen2 and some properties (e.g., blob index, static website) behave differently.
- When using network restrictions, ensure any services or private endpoints that need access are permitted (virtual network subnet IDs or service endpoints).
- Avoid exposing secrets directly; consider using Key Vault for secret storage and referencing via data sources.

## References

- azurerm_storage_account — https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account
- Azure Storage concepts — https://learn.microsoft.com/azure/storage/common/storage-account-overview