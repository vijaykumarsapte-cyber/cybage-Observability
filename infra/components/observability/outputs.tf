output "resource_group_name" {
  value = module.resource_group.rg
}

output "vnet_id" {
  value = module.vnet.virtual_network_id
}

output "acr_login_server" {
  value = module.acr.acr_login_server
}

output "key_vault_uri" {
  value = module.keyvault.keyvault_uri
}

output "storage_account_name" {
  value = var.storage_account_name
}

output "aks_cluster_name" {
  value = module.aks_cluster.aks_cluster_name
}

output "aks_resource_group" {
  value = module.aks_cluster.aks_resource_group
}

output "aks_oidc_issuer_url" {
  value = module.aks_cluster.oidc_issuer_url
}

output "workload_identity_client_id" {
  value = module.workload_identity.client_id
}

output "log_analytics_workspace_id" {
  value = module.log_analytics.la_workspace_id
}