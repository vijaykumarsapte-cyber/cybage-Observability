subscription_id = "e2b40a80-574b-4c80-859c-2003d5b5979b"
location        = "centralindia"

rg_name = "rg-observability-dev"

vnet_name          = "vnet-observability-dev"
vnet_address_space = "10.60.0.0/23"

rg2_name   = "rgdevops"
vnet2_name = "vnet-centralindia-1"

vlinkname  = "aks-private-dns-vm-vnet-link"
aks_private_dns_zone_name = "9cc16ff7-51b4-47fc-a17d-48adaec7c5e9.privatelink.centralindia.azmk8s.io"
aks_private_dns_zone_rg = "MC_rg-observability-dev_aks-observability-dev_centralindia"

app_subnet_name   = "snet-app-observability-dev"
app_subnet_prefix = "10.60.0.0/26"

appgw_subnet_name   = "snet-appgw-observability-dev"
appgw_subnet_prefix = "10.60.0.64/26"

pe_subnet_name   = "snet-pe-observability-dev"
pe_subnet_prefix = "10.60.0.128/26"

nsg_app_name   = "nsg-app-observability-dev"
nsg_appgw_name = "nsg-appgw-observability-dev"
nsg_pe_name    = "nsg-pe-observability-dev"

acr_name = "acrobspocdev"

kv_name = "kv-obs-dev-poc"
kv_pe_name = "pe-obs-dev-poc"

storage_account_name = "stobspocdev"

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
