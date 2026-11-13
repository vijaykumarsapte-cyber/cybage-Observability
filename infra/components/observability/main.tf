locals {
  acr_pe_name        = var.acr_pe_name
  acr_dns_link_name  = "${var.acr_name}-dns-link"
  acr_dns_group_name = "${var.acr_name}-dns-group"

  blob_dns_link_name  = "${var.storage_account_name}-blob-dns-link"

  kv_dns_link_name = "${var.kv_name}-dns-link"

  fed_cred_name = "fic-${var.workload_identity_name}"

  wi_namespace       = "observability"
  wi_service_account = "workload-identity-sa"

  # Container Insights streams collected by the data collection rule
  ci_streams = [
    "Microsoft-ContainerLogV2",
    "Microsoft-KubeEvents",
    "Microsoft-KubePodInventory",
    "Microsoft-KubeNodeInventory",
    "Microsoft-KubeServices",
    "Microsoft-InsightsMetrics",
    "Microsoft-ContainerInventory",
    "Microsoft-ContainerNodeInventory",
  ]
}

# Optional: existing build-agent / jump-box VNet (agent_vnet_rg_name/agent_vnet_name).
# Only looked up when enable_agent_vnet_connectivity = true. It must already exist
# in this subscription. Needed only if a self-hosted agent must reach the private
# ACR / Key Vault / AKS API directly (e.g. docker push to the private ACR).
data "azurerm_virtual_network" "agent" {
  count               = var.enable_agent_vnet_connectivity ? 1 : 0
  name                = var.agent_vnet_name
  resource_group_name = var.agent_vnet_rg_name
}

locals {
  # Extra Private DNS zone links: none unless the agent VNet is enabled.
  dns_additional_vnet_links = var.enable_agent_vnet_connectivity ? {
    agent = data.azurerm_virtual_network.agent[0].id
  } : {}

  # AKS private DNS zone = API server private FQDN without its first label,
  # created by AKS in the node resource group (private_dns_zone_id = "System").
  aks_private_dns_zone_name = join(".", slice(split(".", module.aks_cluster.private_fqdn), 1, length(split(".", module.aks_cluster.private_fqdn))))
}

# 1. Resource Group
module "resource_group" {
  source   = "../../modules/resource_group"
  name     = var.rg_name
  location = var.location
  tags     = var.tags
}

# 2. VNet + App/AppGW/PE Subnets
module "vnet" {
  source              = "../../modules/network/vnet"
  location            = var.location
  resource_group_name = module.resource_group.rg
  vnet_name           = var.vnet_name
  vnet_address_space  = [var.vnet_address_space]
  common_tags         = var.tags
}

module "subnet_app" {
  source                = "../../modules/network/subnet"
  location              = var.location
  resource_group_name   = module.resource_group.rg
  vnet_name             = module.vnet.virtual_network_name
  subnet_name           = var.app_subnet_name
  subnet_address_space  = [var.app_subnet_prefix]
}

module "subnet_appgw" {
  source                = "../../modules/network/subnet"
  location              = var.location
  resource_group_name   = module.resource_group.rg
  vnet_name             = module.vnet.virtual_network_name
  subnet_name           = var.appgw_subnet_name
  subnet_address_space  = [var.appgw_subnet_prefix]
}

module "subnet_pe" {
  source                = "../../modules/network/subnet"
  location              = var.location
  resource_group_name   = module.resource_group.rg
  vnet_name             = module.vnet.virtual_network_name
  subnet_name           = var.pe_subnet_name
  subnet_address_space  = [var.pe_subnet_prefix]
}

# 3. NSGs + associations (via modules/network/nsg)
module "nsg_app" {
  source               = "../../modules/network/nsg"
  nsg_name             = var.nsg_app_name
  location             = var.location
  resource_group_name  = module.resource_group.rg
  subnet_id            = module.subnet_app.subnet_id
  tags                 = var.tags

  security_rules = [
    {
      name                        = "AllowVnetInbound"
      priority                    = 100
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_range      = "*"
      source_address_prefix       = "VirtualNetwork"
      destination_address_prefix  = "VirtualNetwork"
    }
  ]
}

module "nsg_appgw" {
  source               = "../../modules/network/nsg"
  nsg_name             = var.nsg_appgw_name
  location             = var.location
  resource_group_name  = module.resource_group.rg
  subnet_id            = module.subnet_appgw.subnet_id
  tags                 = var.tags

  security_rules = [
    {
      name                        = "AllowGatewayManagerInbound"
      priority                    = 100
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_range      = "65200-65535"
      source_address_prefix       = "GatewayManager"
      destination_address_prefix  = "*"
    },
    {
      name                        = "AllowVnetInbound"
      priority                    = 110
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_range      = "*"
      source_address_prefix       = "VirtualNetwork"
      destination_address_prefix  = "VirtualNetwork"
    },
    # Added: allow inbound Internet traffic on 80/443 so AppGW's public frontend
    # is actually reachable. Without this, AppGW is fully configured and healthy
    # but silently unreachable from outside (found during connectivity testing).
    {
      name                        = "AllowInternetHTTPInbound"
      priority                    = 120
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "Tcp"
      source_port_range           = "*"
      destination_port_range      = "80-443"
      source_address_prefix       = "Internet"
      destination_address_prefix  = "*"
    }
  ]
}

module "nsg_pe" {
  source               = "../../modules/network/nsg"
  nsg_name             = var.nsg_pe_name
  location             = var.location
  resource_group_name  = module.resource_group.rg
  subnet_id            = module.subnet_pe.subnet_id
  tags                 = var.tags

  security_rules = [
    {
      name                        = "AllowVnetInbound"
      priority                    = 100
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_range      = "*"
      source_address_prefix       = "VirtualNetwork"
      destination_address_prefix  = "VirtualNetwork"
    }
  ]
}

# Optional: peer the workload VNet with the build-agent VNet.
module "vnet_peering" {
  count  = var.enable_agent_vnet_connectivity ? 1 : 0
  source = "../../modules/network/vnet-peering"

  vnet1_name           = module.vnet.virtual_network_name
  resource1_group_name = module.resource_group.rg

  vnet2_name           = var.agent_vnet_name
  resource2_group_name = var.agent_vnet_rg_name
}

# 4. ACR + Private DNS + Private Link + Private Endpoint
module "acr" {
  source               = "../../modules/acr"
  resource_group_name  = module.resource_group.rg
  acr_name             = var.acr_name
  acr_location         = var.location
  acr_sku              = "Premium"
  admin_enabled        = false
  public_network_access_enabled = false
}

module "acr_dns_zone" {
  source               = "../../modules/network/privatednszone"
  resource_group_name  = module.resource_group.rg
  private_dns_zone     = "privatelink.azurecr.io"
  dns_link_name        = local.acr_dns_link_name
  vnet_id              = module.vnet.virtual_network_id
  additional_vnet_links = local.dns_additional_vnet_links
  location             = var.location
}

module "acr_pe" {
  source                  = "../../modules/network/privateEndpoint"
  location                = var.location
  resource_group_name     = module.resource_group.rg
  private_endpoint_name   = local.acr_pe_name
  enable_private_endpoint = true
  subnet_id               = module.subnet_pe.subnet_id
  private_dns_zone        = "privatelink.azurecr.io"
  private_dns_zone_group  = local.acr_dns_group_name
  private_dns_zone_ids    = [module.acr_dns_zone.private_dns_zone_id]
  private_resource_id     = module.acr.acr_id
  subresource_names       = ["registry"]
}

# 5. Key Vault + Private DNS + Private Link + Private Endpoint
module "kv_dns_zone" {
  source               = "../../modules/network/privatednszone"
  resource_group_name  = module.resource_group.rg
  private_dns_zone     = "privatelink.vaultcore.azure.net"
  dns_link_name        = local.kv_dns_link_name
  vnet_id              = module.vnet.virtual_network_id
  additional_vnet_links = local.dns_additional_vnet_links
  location             = var.location
}

module "keyvault" {
  source                      = "../../modules/keyvault"
  location                    = var.location
  subscription_id             = var.subscription_id
  resource_group_name         = module.resource_group.rg
  keyvault_name                = var.kv_name
  keyvault_sku_name            = "standard"
  enable_purge_protection      = false
  enable_rbac_authorization    = true
  soft_delete_retention_days   = 7
  public_network               = false
  private_endpoint_subnet_id   = module.subnet_pe.subnet_id
  private_endpoint_name        = var.kv_pe_name

  depends_on = [module.kv_dns_zone]
}

# 6. Blob Storage + Private DNS + Private Link + Private Endpoint
module "storage_dns_zone" {
  source               = "../../modules/network/privatednszone"
  resource_group_name  = module.resource_group.rg
  private_dns_zone     = "privatelink.blob.core.windows.net"
  dns_link_name        = local.blob_dns_link_name
  vnet_id              = module.vnet.virtual_network_id
  additional_vnet_links = local.dns_additional_vnet_links
  location             = var.location
}

module "storage" {
  source                        = "../../modules/storage"
  storage_account_name          = var.storage_account_name
  location                      = var.location
  resource_group_name           = module.resource_group.rg
  tags                          = var.tags
  enable_public_network_access  = false
  enable_shared_access_key      = false
  vnet_id                       = module.vnet.virtual_network_id
  enable_private_endpoint_blob  = true
  private_endpoint_subnet_id    = module.subnet_pe.subnet_id
  private_endpoint_name_blob    = var.blob_pe_name

  depends_on = [module.storage_dns_zone]
}
# 7. AKS - private, multi-nodepool (system/app/observability)
module "aks_cluster" {
  source                          = "../../modules/aks/cluster"
  resource_group_name             = module.resource_group.rg
  location                        = var.location
  subnet_id                       = module.subnet_app.subnet_id
  acr_name                        = var.acr_name
  cluster_name                    = var.aks_name
  use_user_assigned_identity      = false
  cluster_user_assigned_identity  = ""
  dns_prefix                      = var.aks_dns_prefix
  load_balancer_sku               = "standard"
  system_node_vm_size             = var.system_node_vm_size
  system_node_count               = 1
  auto_scaling_enabled            = false
  enable_container_insights       = true
  log_analytics_workspace_id      = module.log_analytics.la_workspace_id
  enable_prometheus_monitoring    = false
  enable_agic                     = true
  application_gateway_id          = module.appgw.application_gateway_id
  enable_aks_kv_secrets_provider  = true
  enable_rbac                     = true
  enable_oidc                     = true
  enable_blob_csi_driver          = true
  enable_disk_csi_driver          = true
  enable_file_csi_driver          = true
  enable_private_cluster          = true
  private_dns_zone_id             = "System"
  common_tags                     = var.tags
}

module "aks_nodepool_app" {
  source          = "../../modules/aks/nodepools"
  node_pool_name  = "app"
  aks_cluster_id  = module.aks_cluster.aks_cluster_id
  node_vm_size    = var.app_node_vm_size
  node_count      = 1
  subnet_id       = module.subnet_app.subnet_id
  common_tags     = var.tags

}

# Optional: link the AKS-managed private DNS zone to the build-agent VNet so the
# agent can resolve the private API server. Zone name/RG are derived from the cluster.
module "aks_vm_privatelink" {
  count                     = var.enable_agent_vnet_connectivity ? 1 : 0
  source                    = "../../modules/aks/pvlink"
  vlinkname                 = var.vlinkname
  aks_private_dns_zone_name = local.aks_private_dns_zone_name
  aks_private_dns_zone_rg   = module.aks_cluster.aks_node_resource_group
  vm_vnet_name              = var.agent_vnet_name
  vm_vnet_rg                = var.agent_vnet_rg_name
}

module "aks_nodepool_observability" {
  source          = "../../modules/aks/nodepools"
  node_pool_name  = "obs"
  aks_cluster_id  = module.aks_cluster.aks_cluster_id
  node_vm_size    = var.observability_node_vm_size
  node_count      = 1
  subnet_id       = module.subnet_app.subnet_id
  node_taints     = ["workload=observability:NoSchedule"]
  common_tags     = var.tags
}

# 8. Identity - Federated Identity (Workload Identity -> Key Vault + Blob)
#    and ACR pull via AKS's own auto-created kubelet identity
module "workload_identity" {
  source               = "../../modules/authorization/userIdentity"
  resource_group_name  = module.resource_group.rg
  location             = var.location
  identity_name        = var.workload_identity_name
  common_tags          = var.tags
}

resource "azurerm_federated_identity_credential" "workload_identity_fed" {
  name                 = local.fed_cred_name
  resource_group_name  = module.resource_group.rg
  parent_id            = module.workload_identity.identity_id
  audience             = ["api://AzureADTokenExchange"]
  issuer                = module.aks_cluster.oidc_issuer_url
  subject               = "system:serviceaccount:${local.wi_namespace}:${local.wi_service_account}"
}

module "kubelet_acr_pull" {
  source     = "../../modules/authorization/roleAssignments"
  scope      = module.acr.acr_id
  role_name  = "AcrPull"
  object_id  = module.aks_cluster.aks_kubelet_principal_id
}

module "workload_identity_kv_secrets_user" {
  source     = "../../modules/authorization/roleAssignments"
  scope      = module.keyvault.keyvault_id
  role_name  = "Key Vault Secrets User"
  object_id  = module.workload_identity.principal_id
}

module "workload_identity_blob_contributor" {
  source     = "../../modules/authorization/roleAssignments"
  scope      = module.storage.storage_account_id
  role_name  = "Storage Blob Data Contributor"
  object_id  = module.workload_identity.principal_id
}

module "workload_identity_acr_pull" {
  source     = "../../modules/authorization/roleAssignments"
  scope      = module.acr.acr_id
  role_name  = "AcrPull"
  object_id  = module.workload_identity.principal_id
}

# 9. PVC/PV for persistent storage - applied via kubectl (az aks command invoke) after apply succeeds.
# Reverted from native Terraform kubernetes provider: the pipeline agent has no network path
# to the private AKS API server (confirmed via DNS lookup failure during apply), so this
# must stay outside Terraform state until agent VNet connectivity is available.

# 10. Ingress - Application Gateway + AGIC add-on (AGIC is built into the AKS cluster module
#     via the ingress_application_gateway block, not a separate module)
module "appgw" {
  source               = "../../modules/application-gateway"
  appgw_name           = var.appgw_name
  resource_group_name  = module.resource_group.rg
  location             = var.location
  subnet_id            = module.subnet_appgw.subnet_id

  sku = {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }

  frontend_ports = {
    port_80 = 80
  }

  backend_address_pools = {
    defaultpool = {}
  }

  probes = {}

  backend_http_settings = {
    defaulthttp = {
      protocol                            = "Http"
      port                                = 80
      cookie_based_affinity               = "Disabled"
      request_timeout                     = 20
      pick_host_name_from_backend_address = false
    }
  }

  http_listeners = {
    defaultlistener = {
      frontend_port_name = "port_80"
      protocol            = "Http"
    }
  }

  request_routing_rules = {
    defaultrule = {
      rule_type                  = "Basic"
      priority                   = 100
      listener_name              = "defaultlistener"
      backend_pool_name          = "defaultpool"
      backend_http_settings_name = "defaulthttp"
    }
  }
}

# AGIC add-on managed identity needs Contributor on the RG containing the App Gateway
# to manage listeners/backend pools/routing rules via Ingress resources. Not auto-granted.
module "agic_identity_contributor" {
  source     = "../../modules/authorization/roleAssignments"
  scope      = module.resource_group.rg_id
  role_name  = "Contributor"
  object_id  = module.aks_cluster.agic_identity_object_id
}

# AKS Key Vault add-on identity needs to read secrets (CSI driver mounts)
module "aks_kv_addon_secrets_user" {
  source     = "../../modules/authorization/roleAssignments"
  scope      = module.keyvault.keyvault_id
  role_name  = "Key Vault Secrets User"
  object_id  = module.aks_cluster.kv_secrets_provider_object_id
}

# 11. Azure Monitor - Log Analytics workspace + AKS diagnostic settings
module "log_analytics" {
  source                       = "../../modules/monitoring/laworkspace"
  location                     = var.location
  resource_group_name          = module.resource_group.rg
  log_analytics_workspace_name = var.log_analytics_workspace_name
  common_tags                  = var.tags
}

module "aks_diagnostics" {
  source                     = "../../modules/monitoring/diagnosticSetting"
  diagnostic_settings_name   = "diag-aks"
  aks_cluster_id             = module.aks_cluster.aks_cluster_id
  log_analytics_workspace_id = module.log_analytics.la_workspace_id
}

# Container Insights data collection rule (DCE + DCR + association) via module.
# Without a DCR the agent (MSI mode) runs but sends no data.
module "container_insights_dcr" {
  source = "../../modules/monitoring/datacollection"

  dce_name             = "dce-ci-${var.log_analytics_workspace_name}"
  dcr_name             = "dcr-ci-${var.log_analytics_workspace_name}"
  dcr_association_name = "ContainerInsightsExtension" # must be exactly this for Container Insights
  location             = var.location
  resource_group_name  = module.resource_group.rg
  target_resource_id   = module.aks_cluster.aks_cluster_id
  common_tags          = var.tags

  data_flows = [
    {
      streams      = local.ci_streams
      destinations = ["law"]
    }
  ]

  data_sources = [
    {
      extensions = [
        {
          name           = "ContainerInsightsExtension"
          extension_name = "ContainerInsights"
          streams        = local.ci_streams
          extension_json = jsonencode({
            dataCollectionSettings = {
              interval               = "1m"
              namespaceFilteringMode = "Exclude"
              namespaces             = ["logging"] # Loki/Alloy/OTel logs already live in Loki; avoids duplicate ingestion cost
              enableContainerLogV2   = true
            }
          })
        }
      ]
    }
  ]

  destinations = [
    {
      log_analytics = {
        name                  = "law"
        workspace_resource_id = module.log_analytics.la_workspace_id
      }
    }
  ]
}
# 12. Diagnostics for managed services -> Log Analytics
locals {
  diagnostic_targets = {
    appgw = {
      target_resource_id = module.appgw.application_gateway_id
      logs               = ["ApplicationGatewayAccessLog"]
      metrics            = ["AllMetrics"]
    }
    keyvault = {
      target_resource_id = module.keyvault.keyvault_id
      logs               = ["AuditEvent"]
      metrics            = ["AllMetrics"]
    }
    acr = {
      target_resource_id = module.acr.acr_id
      logs               = ["ContainerRegistryLoginEvents", "ContainerRegistryRepositoryEvents"]
      metrics            = ["AllMetrics"]
    }
    storage = {
      target_resource_id = module.storage.storage_account_id
      logs               = []
      metrics            = ["Transaction", "Capacity"]
    }
    storage-blob = {
      target_resource_id = "${module.storage.storage_account_id}/blobServices/default"
      logs               = ["StorageRead", "StorageWrite", "StorageDelete"]
      metrics            = ["Transaction"]
    }
  }
}

module "service_diagnostics" {
  for_each = local.diagnostic_targets
  source   = "../../modules/monitoring/resourcediagnostics"

  diagnostic_settings_name   = "diag-${each.key}"
  target_resource_id         = each.value.target_resource_id
  log_analytics_workspace_id = module.log_analytics.la_workspace_id
  log_categories             = each.value.logs
  metric_categories          = each.value.metrics
}
