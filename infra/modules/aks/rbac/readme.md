# Module: AKS RBAC (Azure) — README

Description
This module creates Azure role assignments required for an AKS cluster to operate with the intended identities (managed identities, service principals, or other principals). It supports assigning built-in or custom role definitions to a principal at a specified scope (cluster, node resource group, subnet, resource group, or any resource id).

Usage
Copy this into your root Terraform code to call the module:

```hcl
module "aks_rbac" {
    source = "./modules/aks/rbac"

    # REQUIRED
    subscription_id     = var.subscription_id
    resource_group_name = "rg-aks-prod"
    location            = "eastus"
    aks_cluster_name    = "aks-prod"
    principal_id        = azurerm_user_assigned_identity.aks_identity.principal_id
    role_definition_id  = data.azurerm_role_definition.contributor.id
    scope               = azurerm_kubernetes_cluster.aks.id

    # Optional
    assignment_name        = "aks-rbac-assignment"
    create_role_assignment = true
}
```

Variables
Variables below are marked REQUIRED where Azure resource behavior or common AKS deployment patterns require them. Use the table to copy into your module's variables.tf.

| Name | Type | Default | Required | Description |
|------|------|---------|----------|-------------|
| subscription_id | string | — | YES | Azure subscription id containing the resources. |
| resource_group_name | string | — | YES | Resource group that contains the AKS cluster or target resources. |
| location | string | — | YES | Azure region for resources (e.g., eastus). Marked required to avoid accidental cross-region operations. |
| aks_cluster_name | string | — | YES | AKS cluster name. |
| principal_id | string | — | YES | Object id (principal id) of the identity (user-assigned managed identity / service principal / user) to assign the role to. |
| role_definition_id | string | — | YES | Role definition id (resource id) or use data.azurerm_role_definition to reference by name. |
| scope | string | — | YES | Scope for the role assignment (resource id of the AKS cluster, resource group, subscription, node resource group, subnet, key vault, etc.). |
| assignment_name | string | null | NO | Optional name for the role assignment. If null, a deterministic name will be generated. |
| create_role_assignment | bool | true | NO | Whether to create the role assignment (set to false to skip creation, useful in DR/preview). |
| principal_type | string | "ServicePrincipal" | NO | Principal type used for role assignment (ServicePrincipal, User, Group, msi, etc.). |
| ensure_unique_id_suffix | string | "" | NO | Suffix used when constructing the assignment name to reduce naming collisions. |
| depends_on | list(any) | [] | NO | Optional list to pass references for creation ordering (e.g., depends_on = [azurerm_kubernetes_cluster.aks]). |

Example variables.tf snippet (module-local)
```hcl
variable "subscription_id" {
    type        = string
    description = "REQUIRED: subscription id containing the resources."
}

variable "resource_group_name" {
    type        = string
    description = "REQUIRED: resource group that contains the AKS cluster or target resources."
}
# ... (rest follow the table above)
```

Resources created (typical)
- azurerm_role_assignment — creates an Azure role assignment for the principal at the requested scope.

Sample resource snippet
```hcl
resource "azurerm_role_assignment" "this" {
    count              = var.create_role_assignment ? 1 : 0
    scope              = var.scope
    role_definition_id = var.role_definition_id
    principal_id       = var.principal_id
    principal_type     = var.principal_type
    name               = coalesce(var.assignment_name, substr(format("%s-%s", replace(var.aks_cluster_name, "/","-"), var.ensure_unique_id_suffix), 0, 64))
}
```

Outputs
Include these outputs in outputs.tf. The "role_assignment_id" output depends on create_role_assignment.

| Name | Description | Value |
|------|-------------|-------|
| role_assignment_id | The id of the created role assignment (azurerm_role_assignment). | azurerm_role_assignment.this[0].id |
| assigned_principal_id | The object id of the assigned principal. | var.principal_id |
| assigned_scope | Scope the role was assigned to. | var.scope |
| role_definition_id | Role definition used for the assignment. | var.role_definition_id |

Example outputs.tf snippet
```hcl
output "role_assignment_id" {
    description = "The id of the created role assignment (azurerm_role_assignment)."
    value       = azurerm_role_assignment.this[0].id
    # condition = var.create_role_assignment  # conditional output can be handled in your root module if needed
}

output "assigned_principal_id" {
    description = "The object id of the assigned principal."
    value       = var.principal_id
}
```

Recommendations and best practices
- Scope role assignments as narrowly as possible (prefer resource or resource group scope over subscription scope).
- Use managed identities or dedicated service principals with least privilege.
- For AKS, prefer assigning roles to the cluster's managed identity at the node resource group or to a user-assigned identity bound to the cluster where required.
- Use data.azurerm_role_definition to resolve role ids by name to avoid magic strings.
- When targeting node resource group, read it from the cluster resource (aks.node_resource_group) after creation to avoid mismatches.
- Add explicit depends_on between cluster creation and RBAC assignments when the module is used in the same plan to ensure resource ids exist.

References
- Azure RBAC (concepts): https://learn.microsoft.com/azure/role-based-access-control/overview
- azurerm_role_assignment Terraform docs: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
- AKS managed identity docs: https://learn.microsoft.com/azure/aks/use-managed-identity

If you want, I can generate the module's variables.tf, main.tf and outputs.tf files or adapt the module to create multiple role assignments (map/list input).

GitHub Copilot
