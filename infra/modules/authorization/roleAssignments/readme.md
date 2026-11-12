# Role Assignments Module

This Terraform module creates Azure role assignments (azurerm_role_assignment) to grant specified principals roles for a given scope.

## Usage

```hcl
module "role_assignments" {
  source = "./modules/authorization/roleAssignments"

  # Required
  scope                = "/subscriptions/00000000-0000-0000-0000-000000000000"  # required
  role_definition_id   = "/subscriptions/..../providers/Microsoft.Authorization/roleDefinitions/<role-guid>" # required OR
  # role_definition_name = "Contributor"  # optional alternative if implemented in module

  # Principals to assign the role to (object IDs of service principals, managed identities, groups, users)
  principal_object_ids = [
    "00000000-0000-0000-0000-000000000000",
  ]

  # Optional
  assignment_name_prefix = "ra"   # optional prefix used to construct assignment names
}

# Consume outputs:
output "role_assignment_ids" {
  value = module.role_assignments.role_assignment_ids
}
```

## Variables (common / expected)

| Name                  | Type         | Description                                                                 | Required | Default |
|-----------------------|--------------|-----------------------------------------------------------------------------|----------|---------|
| scope                 | string       | Scope at which the role will be assigned (subscription, resource group, or resource). | Yes      | n/a     |
| role_definition_id    | string       | Full resource ID of the role definition to assign (preferred).             | Yes      | n/a     |
| role_definition_name  | string       | Name of the role (e.g., "Contributor"). If the module supports name lookup, this may be used instead of role_definition_id. | Conditionally | n/a |
| principal_object_ids  | list(string) | List of principal object IDs (service principal, user, group, or managed identity) to receive the role. | Yes      | n/a     |
| assignment_name_prefix| string       | Optional prefix used to build role assignment names to ensure uniqueness.   | No       | ""      |

Notes:
- `scope` and a role identifier (role_definition_id or role_definition_name) are required by Azure for a role assignment.
- `principal_object_ids` must be Azure AD object IDs (GUIDs) — not UPNs or app/client IDs.
- If both `role_definition_id` and `role_definition_name` are supported by the module, prefer `role_definition_id` (explicit).

## Outputs

| Name                  | Description |
|-----------------------|-------------|
| role_assignment_ids   | List of created role assignment IDs (azurerm_role_assignment.*.id) |

## Notes & Recommendations

- Role assignments are eventually consistent; Terraform may report success while role propagation is still in progress.
- Use unique assignment names where required; collisions will cause failures.
- Ensure the identity executing Terraform has Microsoft.Authorization/roleAssignments/write permission at the target scope.
- For built-in roles, you can use role definition IDs from Microsoft docs or list them via Azure CLI.
- Reference: azurerm_role_assignment — https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment