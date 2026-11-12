variable "appgw_name" {
  description = "Name of the Application Gateway"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for Application Gateway"
  type        = string
}

variable "sku" {
  type = object({
    name     = string
    tier     = string
    capacity = number
  })
}

variable "frontend_ports" {
  type = map(number)
}

variable "backend_address_pools" {
  type = map(object({
    ip_addresses = optional(list(string))
    fqdns        = optional(list(string))
  }))
}

variable "probes" {
  type = map(object({
    protocol                                  = string
    path                                      = string
    interval                                  = number
    timeout                                   = number
    unhealthy_threshold                       = number
    pick_host_name_from_backend_http_settings = bool
    match_status_codes                        = list(string)
  }))
}

variable "backend_http_settings" {
  type = map(object({
    protocol                            = string
    port                                = number
    cookie_based_affinity               = string
    request_timeout                     = number
    probe_name                          = optional(string)
    pick_host_name_from_backend_address = bool
  }))
}

variable "http_listeners" {
  type = map(object({
    frontend_port_name   = string
    protocol             = string
    ssl_certificate_name = optional(string)
  }))
}

variable "request_routing_rules" {
  type = map(object({
    rule_type                  = string
    priority                   = number
    listener_name              = string
    backend_pool_name          = string
    backend_http_settings_name = string
  }))
}

variable "ssl_certificates" {
  description = "SSL certificates for HTTPS listeners (Key Vault based)"
  type = map(object({
    key_vault_secret_id = string
  }))
  default = {}
}

variable "firewall_policy_id" {
  type        = string
  description = "WAF policy ID to attach to Application Gateway"
  default     = null
}