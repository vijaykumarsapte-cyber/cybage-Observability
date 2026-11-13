# User-assigned Managed Identity Module

This Terraform module creates an Azure user-assigned managed identity (azurerm_user_assigned_identity).

## Usage

```hcl
module "user_identity" {
  source              = "./modules/authorization/userIdentity"
  resource_group_name = "rg-example"           # required
  location            = "eastus"              # required
  identity_name        = "poc-user-identity"   # required
}

# Consume outputs:
output "identity_id" {
  value = module.user_identity.identity_id
}
```

## Variables

| Name                | Type   | Description                                                          | Required | Default   |
|---------------------|--------|----------------------------------------------------------------------|----------|-----------|
| resource_group_name | string | Name of the existing resource group where the identity will be created. (Required by Azure resource) | Yes      | n/a       |
| location            | string | Azure region where the identity will be created. (Required by Azure resource)                      | Yes      | "eastus" |
| identity_name       | string | Name for the user-assigned managed identity.                          | Yes      | n/a       |

Notes:
- Although `location` has a default in the module, Azure requires a location for the resource. Marked as required to ensure the caller intentionally provides or accepts the default.
- `resource_group_name` and `identity_name` are required for the resource to be created.

## Outputs

| Name         | Description |
|--------------|-------------|
| identity_id  | ID of the user-assigned managed identity (azurerm_user_assigned_identity.user_identity.id) |
| client_id    | Client ID of the user-assigned managed identity (azurerm_user_assigned_identity.user_identity.client_id) |
| principal_id | Principal (object) ID of the user-assigned managed identity (azurerm_user_assigned_identity.user_identity.principal_id) |

## Notes & Recommendations

- Ensure the caller has permission to create identities in the specified resource group.
- Use the `principal_id` to assign RBAC roles to this identity where required.
- Avoid hard-coding sensitive values in Terraform; use variable files or a secret manager where appropriate.

## References

- azurerm_user_assigned_identity documentation: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity