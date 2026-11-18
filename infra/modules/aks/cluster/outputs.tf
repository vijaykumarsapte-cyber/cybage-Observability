output "aks_cluster_id" {
  value = azurerm_kubernetes_cluster.aks.id
}

output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "kube_admin_config" {
  value     = azurerm_kubernetes_cluster.aks.kube_admin_config
  sensitive = true
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.aks.kube_config
  sensitive = true
}

output "aks_kubelet_principal_id" {
  value = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}

output "aks_principal_id" {
  value = azurerm_kubernetes_cluster.aks.identity[0].principal_id
}

output "aks_node_resource_group" {
  value = azurerm_kubernetes_cluster.aks.node_resource_group
}

output "aks_kubelet_uami_client_id" {
  value = azurerm_kubernetes_cluster.aks.kubelet_identity[0].client_id
}

output "aks_resource_group" {
  value = azurerm_kubernetes_cluster.aks.resource_group_name
}

output "oidc_issuer_url" {
  value = azurerm_kubernetes_cluster.aks.oidc_issuer_url
}
output "agic_identity_object_id" {
  description = "Object ID of the AGIC add-on managed identity (null if enable_agic is false)"
  value       = var.enable_agic ? azurerm_kubernetes_cluster.aks.ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id : null
}

output "kv_secrets_provider_object_id" {
  description = "Object ID of the Key Vault secrets provider add-on identity"
  value       = try(azurerm_kubernetes_cluster.aks.key_vault_secrets_provider[0].secret_identity[0].object_id, null)
}

output "private_fqdn" {
  description = "Private FQDN of the API server (private clusters only)"
  value       = azurerm_kubernetes_cluster.aks.private_fqdn
}
