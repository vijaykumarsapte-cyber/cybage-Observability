# Monitor Action Group module

Provisions an Azure Monitor Action Group (azurerm_monitor_action_group) with support for email, SMS and voice receivers. The resource short_name is derived from the action_group_name (first 12 characters).

## Usage

```hcl
module "action_group" {
  source              = "./modules/monitoring/actiongroup"
  resource_group_name = "rg-monitoring"
  action_group_name   = "ag-alerts-prod"

  email_receivers = [
    { name = "oncall", email_address = "oncall@example.com" }
  ]

  sms_receivers = [
    { name = "ops", country_code = "44", phone_number = "7123456789" }
  ]

  voice_receivers = [
    { name = "pager", country_code = "1", phone_number = "5551234567" }
  ]
}
```

Consume outputs:

```hcl
output "action_group_id" {
  value = module.action_group.action_group_id
}
```

## What the module creates

- azurerm_monitor_action_group — Azure Monitor Action Group with configurable email, SMS and voice receivers.

## Variables

| Name               | Type                                                                                | Required | Default   | Description |
|--------------------|-------------------------------------------------------------------------------------|----------|-----------|-------------|
| location           | string                                                                              | no       | "uksouth" | Azure region (unused by resource but available for consistency) |
| resource_group_name| string                                                                              | yes      | n/a       | Name of the resource group |
| action_group_name  | string                                                                              | yes      | n/a       | Name of the Action Group |
| email_receivers    | list(object({name string, email_address string}))                                   | no       | []        | Email receiver definitions |
| sms_receivers      | list(object({name string, country_code string, phone_number string}))               | no       | []        | SMS receiver definitions |
| voice_receivers    | list(object({name string, country_code string, phone_number string}))               | no       | []        | Voice call receiver definitions |

Notes:
- short_name is derived as substr(action_group_name, 0, 12) to meet Azure short name limits.
- Receiver objects must include the listed attributes; empty lists are allowed.

## Outputs

| Name            | Description |
|-----------------|-------------|
| action_group_id | ID of the created azurerm_monitor_action_group |

## Recommendations

- Validate phone numbers and country codes before provisioning.
- Keep sensitive contact details in a secrets manager if needed.
- Ensure the deploying identity has appropriate permissions in the target resource group.

## References

- azurerm_monitor_action_group — https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_action_group