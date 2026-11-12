resource "azurerm_public_ip" "this" {
  name                = "${var.appgw_name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_application_gateway" "this" {
  name                = var.appgw_name
  location            = var.location
  resource_group_name = var.resource_group_name
  firewall_policy_id  = var.firewall_policy_id

  sku {
    name     = var.sku.name
    tier     = var.sku.tier
    capacity = var.sku.capacity
  }

  gateway_ip_configuration {
    name      = "gateway-ip-config"
    subnet_id = var.subnet_id
  }

  dynamic "frontend_port" {
    for_each = var.frontend_ports
    content {
      name = frontend_port.key
      port = frontend_port.value
    }
  }

  frontend_ip_configuration {
    name                 = "frontend-ip"
    public_ip_address_id = azurerm_public_ip.this.id
  }

  dynamic "backend_address_pool" {
    for_each = var.backend_address_pools
    content {
      name         = backend_address_pool.key
      ip_addresses = lookup(backend_address_pool.value, "ip_addresses", null)
      fqdns        = lookup(backend_address_pool.value, "fqdns", null)
    }
  }

  dynamic "probe" {
    for_each = var.probes
    content {
      name                                      = probe.key
      protocol                                  = probe.value.protocol
      path                                      = probe.value.path
      interval                                  = probe.value.interval
      timeout                                   = probe.value.timeout
      unhealthy_threshold                       = probe.value.unhealthy_threshold
      pick_host_name_from_backend_http_settings = probe.value.pick_host_name_from_backend_http_settings
      match {
        status_code = probe.value.match_status_codes
      }
    }
  }

  dynamic "backend_http_settings" {
  for_each = var.backend_http_settings
  content {
    name                                = backend_http_settings.key
    protocol                            = backend_http_settings.value.protocol
    port                                = backend_http_settings.value.port
    cookie_based_affinity               = backend_http_settings.value.cookie_based_affinity
    request_timeout                     = backend_http_settings.value.request_timeout
    probe_name                          = lookup(backend_http_settings.value, "probe_name", null)
    pick_host_name_from_backend_address = backend_http_settings.value.pick_host_name_from_backend_address
    }
  }
 
  dynamic "http_listener" {
    for_each = var.http_listeners
    content {
      name                           = http_listener.key
      frontend_ip_configuration_name = "frontend-ip"
      frontend_port_name             = http_listener.value.frontend_port_name
      protocol                       = http_listener.value.protocol
      ssl_certificate_name           = lookup(http_listener.value, "ssl_certificate_name", null)
    }
  }

  dynamic "ssl_certificate" {
    for_each = var.ssl_certificates
    content {
      name                = ssl_certificate.key
      key_vault_secret_id = ssl_certificate.value.key_vault_secret_id
    }
  }

  dynamic "request_routing_rule" {
    for_each = var.request_routing_rules
    content {
      name                       = request_routing_rule.key
      rule_type                  = request_routing_rule.value.rule_type
      priority                   = request_routing_rule.value.priority
      http_listener_name         = request_routing_rule.value.listener_name
      backend_address_pool_name  = request_routing_rule.value.backend_pool_name
      backend_http_settings_name = request_routing_rule.value.backend_http_settings_name
    }
  }

    lifecycle {
    ignore_changes = [
      backend_address_pool,
      backend_http_settings,
      http_listener,
      probe,
      request_routing_rule,
      url_path_map,
      redirect_configuration,
      frontend_port,
      ssl_certificate,
      tags,
    ]
  }
}