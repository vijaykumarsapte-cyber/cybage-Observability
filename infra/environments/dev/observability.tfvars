subscription_id = "47226097-e6c5-43f7-95c7-865d71699fc9"
tenant_id       = "ea48cb28-034a-4625-85d1-159be074cfab"
location        = "centralindia"

rg_name = "rg-observability-dev"

vnet_name          = "vnet-observability-dev"
vnet_address_space = "10.60.0.0/23"

# Optional build-agent / jump-box VNet connectivity (peering + private DNS links).
# Keep false unless that VNet exists in this subscription.
enable_agent_vnet_connectivity = false
agent_vnet_rg_name             = ""
agent_vnet_name                = ""

app_subnet_name   = "snet-app-observability-dev"
app_subnet_prefix = "10.60.0.0/26"

appgw_subnet_name   = "snet-appgw-observability-dev"
appgw_subnet_prefix = "10.60.0.64/26"

pe_subnet_name   = "snet-pe-observability-dev"
pe_subnet_prefix = "10.60.0.128/26"

nsg_app_name   = "nsg-app-observability-dev"
nsg_appgw_name = "nsg-appgw-observability-dev"
nsg_pe_name    = "nsg-pe-observability-dev"

acr_name = "acrobspocdev01"

kv_name    = "kv-obs-dev-poc01"
kv_pe_name = "pe-kv-obs-dev-poc"

storage_account_name = "stobspocdev01"

aks_name       = "aks-observability-dev"
aks_dns_prefix = "aks-observability-dev"

system_node_vm_size        = "Standard_D2s_v5"
app_node_vm_size           = "Standard_D2s_v5"
observability_node_vm_size = "Standard_D2s_v5"

workload_identity_name = "wi-observability-dev"
appgw_name = "appgw-observability-dev"

acr_pe_name  = "pe-acr-obs-dev-poc"
blob_pe_name = "pe-blob-obs-dev-poc"

log_analytics_workspace_name = "log-observability-dev"

tags = {
  Project     = "observability"
  Environment = "dev"
  Team        = "CDAI"
  CostCenter  = "IT-001"
}
